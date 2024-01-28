use nix_uri::FlakeRef;
use rnix::{self};
use std::fs;
use thiserror::Error;

use super::uri::{parse, ParseNixUriError};

#[derive(PartialEq, Debug)]
pub struct Flake<'a> {
    pub repo: &'a str,
    pub node: Option<String>,
    pub profile: Option<String>,
}

#[derive(Error, Debug)]
pub enum ParseFlakeError {
    #[error("Invalid uri")]
    Uri(ParseNixUriError),
    #[error("Impossible to read flake file at {0}")]
    UnreadableFlakeFileError(String),
}

impl From<ParseNixUriError> for ParseFlakeError {
    fn from(err: ParseNixUriError) -> Self {
        ParseFlakeError::Uri(err)
    }
}

pub fn parse_flake(flake_uri: &str) -> Result<FlakeRef, ParseFlakeError> {
    let flake_ref = parse(flake_uri);

    match flake_ref {
        Ok(flake_ref) => {
            let flake_file = "flake.nix";

            let flake_full_path = format!("{}/{}", flake_uri, flake_file);
            let code = match fs::read_to_string(flake_full_path) {
                Ok(code) => code,
                Err(_err) => {
                    return Err(ParseFlakeError::UnreadableFlakeFileError(
                        flake_uri.to_string(),
                    ))
                }
            };
            let _ast = rnix::Root::parse(&code);
            let tree = rnix::Root::parse(&code).syntax();
            let flake = tree.first_child();
            match flake {
                Some(flake) => {
                    let outputs = flake.last_child().unwrap();
                    let key = outputs.first_token().unwrap();
                    if key.text() == "outputs" {
                        for output in outputs.last_child().unwrap().children() {
                            println!("************\noutputs_la: {:}", output);
                        }
                    } else {
                        return Err(ParseFlakeError::UnreadableFlakeFileError(
                            flake_uri.to_string(),
                        ));
                    }
                }
                None => {
                    return Err(ParseFlakeError::UnreadableFlakeFileError(
                        flake_uri.to_string(),
                    ))
                }
            }
            Ok(flake_ref)
        }
        Err(err) => Err(ParseFlakeError::from(err)),
    }
    // let flake_fragment_start = flake.find('#');
    // let (repo, maybe_fragment) = match flake_fragment_start {
    //     Some(s) => (&flake[..s], Some(&flake[s + 1..])),
    //     None => (flake, None),
    // };

    // let mut node: Option<String> = None;
    // let mut profile: Option<String> = None;
    //
    // if let Some(fragment) = maybe_fragment {
    //     let ast = rnix::parse(fragment);
    //
    //     let first_child = match ast.root().node().first_child() {
    //         Some(x) => x,
    //         None => {
    //             return Ok(DeployFlake {
    //                 repo,
    //                 node: None,
    //                 profile: None,
    //             })
    //         }
    //     };
    //
    //     let mut node_over = false;
    //
    //     for entry in first_child.children_with_tokens() {
    //         let x: Option<String> = match (entry.kind(), node_over) {
    //             (TOKEN_DOT, false) => {
    //                 node_over = true;
    //                 None
    //             }
    //             (TOKEN_DOT, true) => {
    //                 return Err(ParseFlakeError::PathTooLong);
    //             }
    //             (NODE_IDENT, _) => Some(entry.into_node().unwrap().text().to_string()),
    //             (TOKEN_IDENT, _) => Some(entry.into_token().unwrap().text().to_string()),
    //             (NODE_STRING, _) => {
    //                 let c = entry
    //                     .into_node()
    //                     .unwrap()
    //                     .children_with_tokens()
    //                     .nth(1)
    //                     .unwrap();
    //
    //                 Some(c.into_token().unwrap().text().to_string())
    //             }
    //             _ => return Err(ParseFlakeError::Unrecognized),
    //         };
    //
    //         if !node_over {
    //             node = x;
    //         } else {
    //             profile = x;
    //         }
    //     }
    // }
    //
    // Ok(Flake {
    //     repo,
    //     node,
    //     profile,
    // })
}

#[cfg(test)]
pub mod tests {

    // #[test]
    // fn parse_in_project_flake() {
    //     let uri = "/home/dauliac/ghq/gitlab.com/conformism/jardin";
    //     parse_flake(uri);
    //     assert!(false);
    // }
}
