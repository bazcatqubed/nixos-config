# A bunch of data-related tools and libraries.
{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.dev.data = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.dev.data.enable {
    my.packages = with pkgs; [
      cfitsio       # A data library for FITS images which is an image used for analyzing your fitness level.
      hdf5          # A binary data format with hierarchy and metadata.
      hdfview       # HDF4 and HDF5 viewer.
      jq            # A JSON parser on the command-line (with the horrible syntax, in my opinion).
      pup           # A cute little puppy that can understand HTML.
      sqlite        # A cute little battle-tested library for your data abominations.
    ];
  };
}
