{ lib, stdenv, blender }:

lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  excludeDrvArgNames = [
    "blenderPackage"
  ];
  extendDrvArgs =
    finalAttrs:
    {
      blenderPackage ? blender,
      blenderAddons ? [ ],
      ...
    }
    @args:
    let blenderVersion = lib.versions.majorMinor blenderPackage.version;
    in
    {
      passAsFile = args.passAsFile or [ ] ++ [ "paths" ];
      paths = blenderAddons ++ [ blenderPackage ];
      buildCommand = ''
        mkdir -p $out
        for i in $(cat $pathsPath); do
          resourcesPath="$i/share/blender"
          if [ -d $i/share/blender/${blenderVersion} ]; then
            resourcesPath="$i/share/blender/${blenderVersion}";
          fi
          cp -r $resourcesPath $out
        done
      '';

      meta = {
        description = "Addons for Blender ${blenderPackage.version}";
        platforms = blenderPackage.meta.platforms;
      };
    };
}
