_:
let
  # TODO: should we move this into infrastructure layer
  cloudflare = [ "1.1.1.1" "1.0.0.1" ];
  google = "8.8.8.8";
  quad9 = [ "9.9.9.9" ];
  privacy = quad9 ++ cloudflare;
  nonPrivacy = privacy ++ [ google ];
in
{
  configure = { nameServerModel }: {
    mkNameservers = _:
      if nameServerModel.privacyFriendly
      then privacy
      else nonPrivacy;
  };
}
