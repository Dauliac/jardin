use thiserror::Error;

#[derive(Error, Debug, Clone, PartialEq, Hash, Eq)]
pub enum ConfigError {
    #[error("Bad config format {0}")]
    BadFormat(String),
    #[error("Bad config directory {0}")]
    BadConfigDirectory(String),
    #[error("Can't have empty pipeline without default_pipeline enabled")]
    EmptyPipeline,
    #[error("Unknown error")]
    Unknown,
}
