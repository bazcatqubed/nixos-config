# It just contains a set of network-related variables mainly used for
# network-related services. Make sure to change this every time you migrate to
# a new server.
let
  inherit (builtins) toString;
in
rec {
  privateIPv6Prefix = "fdee:b0de:5685";

  clientNetworks = [
    "172.24.0.0/13"
    "10.128.0.0/9"
  ];
  serverNetworks = [
    "172.16.0.0/13"
    "10.0.0.0/9"
  ];

  interfaces = let
    ploverInternalNetworkGateway = "172.16.0.1";
    widdeerLan = "10.0.0.1";
    ipv6Gateway = "fe80::1";
  in
    {
    # This is the public-facing interface. Any interface name with a prime
    # symbol means it's a public-facing interface.
    main' = {
      # The gateways for the public addresses are retrieved from the following
      # pages:
      #
      # * https://docs.hetzner.com/cloud/networks/faq/#are-any-ip-addresses-reserved
      # * https://docs.hetzner.com/robot/dedicated-server/ip/additional-ip-adresses/#gateway
      IPv4 = {
        address = "65.109.224.213";
        gateway = "172.31.1.1";
      };
      IPv6 = {
        address = "2a01:4f9:c012:607a::1";
        gateway = ipv6Gateway;
      };
    };

    # /16 block for IPv4, /64 for IPv6.
    internal = {
      IPv4 = {
        address = "172.27.0.1";
        gateway = ploverInternalNetworkGateway;
      };
      IPv6 = {
        address = "${privateIPv6Prefix}:1::";
        gateway = ipv6Gateway;
      };
    };

    # /16 BLOCK for IPv4, /64 for IPv6.
    wireguard0 = {
      IPv4 = {
        address = "10.210.0.1";
        gateway = widdeerLan;
      };
      IPv6 = {
        address = "${privateIPv6Prefix}:12ae::";
        gateway = ipv6Gateway;
      };
    };
  };

  # Wireguard-related things.
  wireguardPort = 51820;
  wireguardIPHostPart = "10.210.0";
  wireguardIPv6Prefix = interfaces.wireguard0.IPv6.address;

  # These are all fixed IP addresses. They should be /32 IPv4 block and /128
  # IPv6 block.
  wireguardPeers = {
    server = with interfaces.wireguard0; {
      IPv4 = IPv4.address;
      IPv6 = IPv6.address;
    };
    desktop = {
      IPv4 = "${wireguardIPHostPart}.2";
      IPv6 = "${wireguardIPv6Prefix}2";
    };
    phone = {
      IPv4 = "${wireguardIPHostPart}.3";
      IPv6 = "${wireguardIPv6Prefix}3";
    };
  };

  secondaryNameServers = {
    "ns1.first-ns.de." = {
      IPv4 = [ "213.239.242.238" ];
      IPv6 = [ "2a01:4f8:0:a101::a:1" ];
    };
    "robotns2.second-ns.de." = {
      IPv4 = [ "213.133.105.6" ];
      IPv6 = [ "2a01:4f8:d0a:2004::2" ];
    };
    "robotns3.second-ns.com." = {
      IPv4 = [ "193.47.99.3" ];
      IPv6 = [ "2001:67c:192c::add:a3" ];
    };
  };
}
