_: {
  mkCommand =
    { bin
    , action ? null
    , globalFlags ? [ ]
    , localFlags ? [ ]
    , valuedActionFlags ? [ ]
    ,
    }:
    let
      mkFlag = flag:
        if builtins.isString flag
        then flag
        else "${flag.flag}=${flag.value}";
      joinFlags = flags:
        builtins.concatStringsSep " " (builtins.map mkFlag flags);

      globalFlagsStr = joinFlags globalFlags;
      localFlagsStr = joinFlags localFlags;
      valuedActionFlagsStr = joinFlags valuedActionFlags;

      commandStr =
        builtins.concatStringsSep " "
          (builtins.filter (s: s != null) [
            bin
            action
            globalFlagsStr
            localFlagsStr
            valuedActionFlagsStr
          ]);
    in
    { command = commandStr; };
}
