// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use thiserror::Error;

#[derive(Error, Debug, Clone, PartialEq, Hash, Eq)]
pub enum ConfigError {
    #[error("Bad config format {0}")]
    BadConfiguration(String),
    #[error("Bad config directory {0}")]
    BadConfigDirectory(String),
    #[error("Can't have empty pipeline without default_pipeline enabled")]
    EmptyPipeline,
    #[error("Can't use pipeline without identifier")]
    NoPipelineIdentifier,
    #[error("Unknown error")]
    Unknown,
}
