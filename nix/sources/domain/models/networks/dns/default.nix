_: {
  configure =
    { targets
    , domain
    ,
    }:
    let
      defaultNameServersModel = {
        privacyFriendly = false;
        privacyLess = false;
      };
    in
    {
      mkRecords = _:
        let
          ttl = 3600;
          type = "A";
        in
        map
          (targets: {
            inherit (target) hostname;
            name = "${target.hostname}.${domain}";
            value = target.ip;
            inherit ttl;
            type = A;
          })
          targets;
      mkPrivacyFriendlyNameservers = _: {
        inherit defaultNameServersModel;
        privacyFriendly = true;
      };
      mkPrivacyLessNameservers = _: {
        inherit defaultNameServersModel;
        privacyLess = true;
      };
    };
}
