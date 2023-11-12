// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

pub mod flake;
pub mod uri;

use std::path::PathBuf;

use crate::application::services::config::model::Config;

use super::configuration::BackendConfiguration;

pub struct NixBackendConfiguration {
    pub version: String,
    pub config: BackendConfiguration,
    // pub flake_output: Outputs,
}

pub enum NixExecutorError {
    Uri(nix_uri::NixUriError),
}

pub trait NixExecutor {
    fn run() -> NixExecutorError;
}

pub struct PipedNixBackend {
    path: PathBuf,
    config: Config,
}

pub struct FlakedNixBackend {
    path: PathBuf,
}

impl FlakedNixBackend {
    fn new(path: PathBuf) -> Self {
        Self { path }
    }
}

// impl NixExecutor for FlakedNixBackend {
//     fn run() -> NixExecutorError {}
// }
