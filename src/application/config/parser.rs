use std::path::PathBuf;

use confy::ConfyError;

use crate::application::NAME;

use super::{error::ConfigError, model::Config};

fn check_empty_pipeline_specification(config: &Config) -> Result<(), ConfigError> {
    let invalid_pipeline = config.pipeline.steps.is_none();
    match invalid_pipeline {
        true => Err(ConfigError::EmptyPipeline),
        false => Ok(()),
    }
}

fn check_pipeline_key_specification(config: &Config) -> Result<(), ConfigError> {
    let constraint = config.pipeline.identifier.is_none();
    match constraint {
        true => Err(ConfigError::NoPipelineIdentifier),
        false => Ok(()),
    }
}

fn confy_error_adapter(error: ConfyError) -> ConfigError {
    match error {
        ConfyError::BadTomlData(error) => ConfigError::BadConfiguration(error.to_string()),
        ConfyError::BadConfigDirectory(error) => ConfigError::BadConfigDirectory(error),
        ConfyError::DirectoryCreationFailed(_) => ConfigError::Unknown,
        ConfyError::GeneralLoadError(_) => ConfigError::Unknown,
        ConfyError::SerializeTomlError(_) => ConfigError::Unknown,
        ConfyError::WriteConfigurationFileError(_) => ConfigError::Unknown,
        ConfyError::ReadConfigurationFileError(_) => ConfigError::Unknown,
        ConfyError::OpenConfigurationFileError(_) => ConfigError::Unknown,
    }
}

pub fn parse_config(config_path: Option<&String>) -> Result<Config, ConfigError> {
    let config = config_path
        .map_or_else(|| confy::load(NAME, None), confy::load_path)
        .map_err(confy_error_adapter)?;
    check_pipeline_key_specification(&config)?;
    check_empty_pipeline_specification(&config).map(|_| config)
}

pub fn get_get_default_config_path() -> Result<PathBuf, ConfigError> {
    confy::get_configuration_file_path(NAME, None).map_err(confy_error_adapter)
}
