use crate::application::{
    command_line_interface::presenter::CliError,
    config::{error::ConfigError, model::Config},
};
use clap::ArgMatches;

pub fn read_config(
    matches: &ArgMatches,
    config_service: impl FnOnce(Option<&String>) -> Result<Config, ConfigError>,
) -> Result<Config, CliError> {
    config_service(matches.get_one::<String>("config")).map_err(CliError::Config)
}
