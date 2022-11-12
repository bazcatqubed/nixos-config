# All-encompassing environment for cloud platform management. I'm using only
# one so far but apparently these providers have some tool to enable easy
# access and usage for their platform.
#
# The reason why we have these with a light sandbox is for more sophiscated
# tools like in Google Cloud SDK.
{ buildFHSUserEnv }:

(buildFHSUserEnv {
  name = "cloud-admin-env";
  targetPkgs = pkgs: (with pkgs; [
    awscli2
    azure-cli
    (google-cloud-sdk.withExtraComponents
      (with google-cloud-sdk.components; [
        gke-gcloud-auth-plugin
        gcloud-man-pages
        cloud-run-proxy
      ])
    )
    kubectl
    hcloud
    linode-cli
    vultr-cli
    python3
  ]);
}).env
