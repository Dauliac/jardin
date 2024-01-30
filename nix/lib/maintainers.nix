{ config
, inputs
, pkgs
, flake-parts-lib
, ...
}: {
  flake = {
    lib.maintainers = {
      dauliac = {
        email = "dauliac";
        github = "dauliac";
        githubId = 12;
        name = "Dauliac";
      };
    };
  };
}
