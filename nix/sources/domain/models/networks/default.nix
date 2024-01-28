_:
let
  dns = import ./dns/default.nix;
in
{
  configure = { config }: {
    dns = dns.configure {
      inherit
        (config.targets)
        ;
      inherit
        (config.domain)
        ;
    };
  };
}
