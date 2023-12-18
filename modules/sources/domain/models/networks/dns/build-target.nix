{
  targets,
  domain,
}: let
  ttl = 3600;
  type = "A";
in
  map (target: {
    hostname = target.hostname;
    name = "${target.hostname}.${domain}";
    value = target.ip;
    ttl = ttl;
    type = A;
  })
  targets
