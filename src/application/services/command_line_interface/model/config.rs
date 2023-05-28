// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use clap::ArgMatches;

use crate::application::services::{
    command_line_interface::presenter::CliError,
    config::{error::ConfigError, model::Config},
};

pub fn read_config(
    matches: &ArgMatches,
    config_service: impl Fn(Option<&String>) -> Result<Config, ConfigError>,
) -> Result<Config, CliError> {
    config_service(matches.get_one::<String>("config")).map_err(CliError::Config)
}
