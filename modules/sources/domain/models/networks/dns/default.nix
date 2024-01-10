_: {
  configure =
    { targets
    , domain
    ,
    }: {
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
    };
}
