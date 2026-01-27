# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{ buildHugoSite, lib }:

buildHugoSite {
  pname = "foodogsquared-hm-startpage";
  version = "0.3.0";
  src = lib.cleanSource ./.;

  vendorHash = "sha256-Mi61QK1yKWIneZ+i79fpJqP9ew5r5vnv7ptr9YGq0Uk=";

  preBuild = ''
    install -Dm0644 ${../tinted-theming/base16/bark-on-a-tree.yaml} ./data/foodogsquared-homepage/themes/_dark.yaml
    install -Dm0644 ${../tinted-theming/base16/albino-bark-on-a-tree.yaml} ./data/foodogsquared-homepage/themes/_light.yaml
  '';

  meta = with lib; {
    description = "foodogsquared's homepage";
    license = licenses.gpl3Only;
  };
}
