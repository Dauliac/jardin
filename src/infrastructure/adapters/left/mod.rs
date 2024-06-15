pub mod nix;
use nix::Response as NixResponse;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, PartialEq, Clone)]
pub enum Response {
    Nix(NixResponse),
}
