pub mod model;
pub mod presenter;

use self::{
    model::{
        completion::attempt_generate_completion_on_match, config::read_config,
        deploy::attempt_deploy_on_match, help::attempt_help_display_on_match,
    },
    presenter::{build_cli, CliError},
};
use super::config::{error::ConfigError, model::Config};
use crate::{application::exit::error_exit, domain::use_cases::UseCases};

fn exit_on_cli_error(error: CliError) {
    log::error!("{}", error.to_string());
    error_exit();
}

pub fn start_cli(
    config_service: impl Fn(Option<&String>) -> Result<Config, ConfigError>,
) -> Result<(Config, UseCases), ()> {
    let matches = build_cli().get_matches();
    attempt_help_display_on_match(&matches)
        .map_err(exit_on_cli_error)
        .map(|_| {
            attempt_generate_completion_on_match(&matches);
        })
        .and_then(|_| {
            read_config(&matches, config_service)
                .map_err(|error| {
                    log::error!(
                        "{}",
                        match error {
                            CliError::Config(error) => error.to_string(),
                        }
                    );
                    error_exit();
                })
                .and_then(|config| {
                    attempt_deploy_on_match(&matches)
                        .ok_or(())
                        .map(|use_case| (config, use_case))
                })
        })
}
