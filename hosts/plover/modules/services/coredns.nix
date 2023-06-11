{ config, options, lib, pkgs, ... }:

# Take note we're also running with systemd-resolved which shouldn't really
# conflict much with established DNS servers default configuration considering
# it lives in 127.0.0.53 (not 127.0.0.1). So if you found some errors, that's
# on you. Either that or we can easily move the resolver somewhere else.
let
  inherit (config.networking) domain fqdn;
  inherit (import ../hardware/networks.nix) privateIPv6Prefix interfaces clientNetworks serverNetworks secondaryNameServers wireguardPeers;

  dnsSubdomain = "ns1";
  dnsDomainName = "${dnsSubdomain}.${domain}";
  certs = config.security.acme.certs;

  corednsServiceName = "coredns";

  domainZoneFile = pkgs.substituteAll {
    src = ../../config/coredns/${domain}.zone;
    ploverPublicIPv4 = interfaces.main'.IPv4.address;
    ploverPublicIPv6 = interfaces.main'.IPv6.address;
  };

  # The final location of the thing.
  domainZoneFile' = "/etc/coredns/zones/${domain}.zone";

  secondaryNameserverDomains = lib.attrNames secondaryNameServers;
  secondaryNameServersIPv4 = lib.foldl'
    (total: addresses: total ++ addresses.IPv4)
    [ ]
    (lib.attrValues secondaryNameServers);
  secondaryNameServersIPv6 = lib.foldl'
    (total: addresses: total ++ addresses.IPv6)
    [ ]
    (lib.attrValues secondaryNameServers);
  secondaryNameServersIPs = secondaryNameServersIPv4 ++ secondaryNameServersIPv6;

  # The local network segments.
  allowedIPs = secondaryNameServersIPv4 ++ [ "172.16.0.0/12" ];
  allowedIPv6s = secondaryNameServersIPv6 ++ [ "${privateIPv6Prefix}::/48" ];

  dnsListenInterfaces = (with interfaces; [
    # For whatever reason, I would say though I don't think it is wise to
    # attach one in this interface.
    internal.IPv4.address
    internal.IPv6.address

    # This is needed for the secondary name servers to reach the DNS records
    # (or at least I think).
    main'.IPv4.address
    main'.IPv6.address
  ]) ++ (with wireguardPeers.server; [
    # This is for use from Wireguard peers.
    IPv4 IPv6
  ]);
in
{
  sops.secrets =
    let
      getKey = key: {
        inherit key;
        sopsFile = ../../secrets/secrets.yaml;
      };
      getSecrets = secrets:
        lib.mapAttrs'
          (secret: config:
            lib.nameValuePair
              "plover/${secret}"
              ((getKey secret) // config))
          secrets;
    in
    getSecrets {
      "dns/${domain}/mailbox-security-key" = { };
      "dns/${domain}/mailbox-security-key-record" = { };
    };

  # Generating a certificate for the DNS-over-TLS feature.
  security.acme.certs."${dnsDomainName}".postRun = ''
    systemctl restart ${corednsServiceName}.service
  '';

  # Setting up the firewall to make less things to screw up in case anything is
  # screwed up.
  networking.firewall.extraInputRules = ''
    meta l4proto {tcp, udp} th dport domain ip saddr { ${lib.concatStringsSep ", " allowedIPs} } accept comment "Accept DNS queries from secondary nameservers and private networks"
    meta l4proto {tcp, udp} th dport domain ip6 saddr { ${lib.concatStringsSep ", " allowedIPv6s} } accept comment "Accept DNS queries from secondary nameservers and private networks"
  '';

  networking.nameservers = dnsListenInterfaces;

  # The main DNS server.
  services.coredns = {
    enable = true;

    # NOTE: Currently, Hetzner DNS servers does not support DNSSEC. Will need
    # to visit the following document periodically to see if they support but
    # it is doubtful since they are doubting the benefits of supporting it. :(
    #
    # From what I can tell, it seems like DNSSEC is not much embraced by the
    # major organizations yet so I'll wait with them on this one.
    #
    # https://docs.hetzner.com/dns-console/dns/general/dnssec
    config = ''
      . {
        forward . /etc/resolv.conf

        log ${domain} ${fqdn} {
          class success error
        }

        errors {
          consolidate 1m "^.* no next plugin found$"
          consolidate 5m "^.* i/o timeout$"
        }

        bind ${lib.concatStringsSep " " dnsListenInterfaces} {
          # These are already taken from systemd-resolved.
          except 127.0.0.53 127.0.0.54
        }

        acl ${domain} {
          # We're setting this up as a "hidden" primary server.
          allow type AXFR net ${lib.concatStringsSep " " secondaryNameServersIPs}
          allow type IXFR net ${lib.concatStringsSep " " secondaryNameServersIPs}

          # This will allow internal clients connect to the subdomains that
          # have internal resources.
          allow net ${lib.concatStringsSep " " (clientNetworks ++ serverNetworks)}
          allow net 127.0.0.0/8 ::1

          # Otherwise, it's just really a primary server that is hidden
          # somewhere (or just very shy, whichever of the two).
          block
        }

        # ${fqdn} DNS server blocks. This is an internal DNS server so we'll
        # only allow queries from the internal network.
        acl ${fqdn} {
          allow net ${lib.concatStringsSep " " (clientNetworks ++ serverNetworks)}
          allow net 127.0.0.0/8 ::1
          block
        }

        template IN A ${fqdn} {
          answer "{{ .Name }} IN 60 A ${interfaces.internal.IPv4.address}"
        }

        template IN AAAA ${fqdn} {
          answer "{{ .Name }} IN 60 AAAA ${interfaces.internal.IPv6.address}"
        }

        file ${domainZoneFile'} ${domain} {
          reload 30s
        }

        transfer ${domain} {
          to ${lib.concatStringsSep " " secondaryNameServersIPs}
        }
      }
    '';
  };

  # This is based from the Gitea pre-start script.
  systemd.services.${corednsServiceName} = {
    requires = [ "acme-finished-${dnsDomainName}.target" ];

    preStart =
      let
        secretsPath = path: config.sops.secrets."plover/${path}".path;
        replaceSecretBin = "${lib.getBin pkgs.replace-secret}/bin/replace-secret";
      in
      lib.mkBefore ''
        install -Dm0644 ${domainZoneFile} ${domainZoneFile'}

        ${replaceSecretBin} '#mailboxSecurityKey#' '${secretsPath "dns/${domain}/mailbox-security-key"}' '${domainZoneFile'}'
        ${replaceSecretBin} '#mailboxSecurityKeyRecord#' '${secretsPath "dns/${domain}/mailbox-security-key-record"}' '${domainZoneFile'}'
      '';

    # Though DNSSEC is disabled for now, we'll set it up in anticipation.
    serviceConfig.LoadCredential =
      let
        certDirectory = certs."${dnsDomainName}".directory;
      in
      [
        "cert.pem:${certDirectory}/cert.pem"
        "key.pem:${certDirectory}/key.pem"
        "fullchain.pem:${certDirectory}/fullchain.pem"
      ];
  };
}
