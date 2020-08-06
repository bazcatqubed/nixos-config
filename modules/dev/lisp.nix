# Lisp is great, easy to learn, and weird.
# I've been using it to study creating languages and the famous SICP book.
# FUN FACT: Lisp is a family of languages with those parenthesis representing the mouth lisp, demonstrating how genetics work.
{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.dev.lisp;
in
{
  options.modules.dev.lisp =
    let mkBoolDefault = bool: mkOption {
      type = types.bool;
      default = bool;
    }; in {
      clojure.enable = mkBoolDefault false;
      guile.enable = mkBoolDefault false;
      racket.enable = mkBoolDefault false;
  };

  config = {
    home.packages = with pkgs;
      (if cfg.clojure.enable then [
        clojure     # Improved Java version.
      ] else []) ++

      (if cfg.guile.enable then [
        guile       # A general-purpose language for stuff, named after a certain American pop culture icon.
      ] else []) ++

      (if cfg.racket.enable then [
        racket      # A DSL for DSLs.
      ] else []);
  };
}
