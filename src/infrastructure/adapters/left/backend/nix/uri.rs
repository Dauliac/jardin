// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use nix_uri::{FlakeRef, FlakeRefType, NixUriError};
use thiserror::Error;

#[derive(Error, Debug, Clone, PartialEq)]
pub enum ParseNixUriError {
    #[error("This type of flakes uri are not currently supported")]
    NotSupportedType(FlakeRef),
    #[error("Provided uri is not valid")]
    InvalidUri,
}

impl From<NixUriError> for ParseNixUriError {
    fn from(_err: NixUriError) -> Self {
        ParseNixUriError::InvalidUri
    }
}

pub fn parse(uri: &str) -> Result<FlakeRef, ParseNixUriError> {
    match uri.try_into() {
        Ok(flake_ref) => {
            let flake_ref: FlakeRef = flake_ref;
            match flake_ref.clone().r#type {
                FlakeRefType::Path { path: _ } => Ok(flake_ref),
                _ => Err(ParseNixUriError::NotSupportedType(flake_ref)),
            }
        }
        Err(err) => Err(ParseNixUriError::from(err)),
    }
}
