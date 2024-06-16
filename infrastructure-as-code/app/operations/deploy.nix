_: {
  config = {
    infra = {
      octodns.enable = true;
    };
    flake = {
      jardin = {
        infra = {
          octodns = {
            enable = true;
            # TODO:  use domain to fill this
            records = ["node1.nofreedisk.space" "node2.nofreedisk.space"];
            provider = "cloudflare";
          };
        };
      };
    };
  };
}
