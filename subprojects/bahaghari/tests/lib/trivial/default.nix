{ pkgs, lib }:

let
  customOctalGlyphs = {
    "0" = "A";
    "1" = "B";
    "2" = "C";
    "3" = "D";
    "4" = "E";
    "5" = "F";
    "6" = "G";
    "7" = "H";
  };

  customBase24Glyphs = {
    "0" = "0";
    "1" = "1";
    "2" = "2";
    "3" = "3";
    "4" = "4";
    "5" = "5";
    "6" = "6";
    "7" = "7";
    "8" = "8";
    "9" = "9";
    "10" = "A";
    "11" = "B";
    "12" = "C";
    "13" = "D";
    "14" = "E";
    "15" = "F";
    "16" = "G";
    "17" = "H";
    "18" = "I";
    "19" = "J";
    "20" = "M";
    "21" = "N";
    "22" = "O";
    "23" = "P";
  };
in
pkgs.lib.runTests {
  testGenerateCustomGlyphSet = {
    expr = lib.trivial.generateGlyphSet [ "A" "B" "C" "D" "E" "F" "G" "H" ];
    expected = customOctalGlyphs;
  };

  testGenerateBase24GlyphSet = {
    expr =
      lib.trivial.generateGlyphSet
        [ "0" "1" "2" "3" "4" "5" "6" "7"
          "8" "9" "A" "B" "C" "D" "E" "F"
          "G" "H" "I" "J" "M" "N" "O" "P" ];
    expected = customBase24Glyphs;
  };

  testBaseDigitWithCustomOctalGlyph = {
    expr = lib.trivial.toBaseDigitsWithGlyphs 8 9 customOctalGlyphs;
    expected = "BB";
  };

  testBaseDigitWithCustomOctalGlyph2 = {
    expr = lib.trivial.toBaseDigitsWithGlyphs 8 641 customOctalGlyphs;
    expected = "BCAB";
  };

  testBaseDigitWithProperBase24Glyph = {
    expr = lib.trivial.toBaseDigitsWithGlyphs 24 641 customBase24Glyphs;
    expected = "12H";
  };

  testBaseDigitWithProperBase24Glyph2 = {
    expr = lib.trivial.toBaseDigitsWithGlyphs 24 2583 customBase24Glyphs;
    expected = "4BF";
  };

  # We're mainly testing if the underlying YAML library is mostly compliant
  # with whatever it claims.
  testImportBasicYAML = {
    expr = lib.trivial.importYAML ./simple.yml;
    expected = {
      hello = "there";
      how-are-you-doing = "I'm fine. Thank you for asking.\n";
      "It's a number" = 53;
      dog-breeds = [ "chihuahua" "golden retriever" ];
    };
  };

  testImportTintedThemingBase16YAML = {
    expr = lib.trivial.importYAML ../tinted-theming/sample-base16-scheme.yml;
    expected = {
      system = "base16";
      name = "Bark on a tree";
      author = "Gabriel Arazas (https://foodogsquared.one)";
      description = "Rusty theme resembling forestry inspired from Nord theme.";
      variant = "dark";
      palette = {
        base00 = "2b221f";
        base01 = "412c26";
        base02 = "5c362c";
        base03 = "a45b43";
        base04 = "e1bcb2";
        base05 = "f5ecea";
        base06 = "fefefe";
        base07 = "eb8a65";
        base08 = "d03e68";
        base09 = "df937a";
        base0A = "afa644";
        base0B = "85b26e";
        base0C = "eb914a";
        base0D = "c67f62";
        base0E = "8b7ab9";
        base0F = "7f3F83";
      };
    };
  };

  # YAML is a superset of JSON (or was it the other way around?) after v1.2.
  testToYAML = {
    expr = lib.trivial.toYAML { } { hello = "there"; };
    expected = "{\"hello\":\"there\"}";
  };
}
