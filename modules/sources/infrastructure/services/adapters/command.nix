{}: {
  build = (
    {
      bin,
      action,
      globalFlags,
      localFlags,
    }: let
      separator = " ";
      action =
        if action == null
        then ""
        else action;
      extendFlags = flag: "${flag.key}${separator}${separator.value}";
      extendedGlobalFlags =
        buildtins.map
        extendFlags
        globalFlags;
      extendedLocalFlagsFlags =
        buildtins.map
        extendFlags
        localFlags;
    in {
      command = "${bin}${separator}${extendedGlobalFlags}${separator}${action}${separator}${extendedLocalFlags}";
    }
  );
}
