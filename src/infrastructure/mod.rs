pub mod adapters;

use self::adapters::left::nix::Response as NixResponse;

use adapters::left::Response as LeftResponse;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, PartialEq, Clone)]
pub enum Response {
    Left(LeftResponse),
    Right(),
}

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum ResponseKind {
    Output,
    Error,
    Left,
    Right,
    LeftNix,
    LeftNixLog,
}

impl From<Response> for Vec<ResponseKind> {
    fn from(value: Response) -> Self {
        match value {
            Response::Left(left) => match left {
                LeftResponse::Nix(nix) => match nix {
                    NixResponse::Log(_) => {
                        vec![
                            ResponseKind::Left,
                            ResponseKind::LeftNix,
                            ResponseKind::LeftNixLog,
                        ]
                    }
                },
            },
            Response::Right() => vec![ResponseKind::Right],
        }
    }
}
