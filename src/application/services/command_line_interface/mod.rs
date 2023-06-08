// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

pub mod model;
pub mod presenter;

use crate::application::services::{
    exit::error_exit,
    logger::{
        init_logger,
        types::{ApplicationLoggerType, LoggerType},
    },
};

use self::{
    model::{
        completion::attempt_generate_completion_on_match, config::read_config,
        deploy::attempt_deploy_on_match, help::attempt_help_display_on_match,
    },
    presenter::{build_cli, CliError},
};

use super::{
    config::{error::ConfigError, model::Config},
    use_cases::start_domain_service,
};

fn exit_on_cli_error(error: CliError, logger_type: &LoggerType) {
    init_logger(false, logger_type).ok();
    log::error!("{}", error);
    error_exit();
}

pub fn start_cli(
    config_service: impl Fn(Option<&String>) -> Result<Config, ConfigError>,
    callback: impl Fn(Config),
) {
    let matches = build_cli().get_matches();
    attempt_help_display_on_match(&matches)
        .map_err(|error| {
            exit_on_cli_error(
                error,
                &LoggerType::Application(ApplicationLoggerType::CommandLineInterface),
            )
        })
        .map(|_| {
            attempt_generate_completion_on_match(&matches)
                .map_err(|error| {
                    exit_on_cli_error(
                        error,
                        &LoggerType::Application(ApplicationLoggerType::CommandLineInterface),
                    )
                })
                .ok();
        })
        .map(|_| {
            read_config(&matches, config_service)
                .map_err(|error| {
                    init_logger(
                        false,
                        &LoggerType::Application(ApplicationLoggerType::Config),
                    )
                    .ok();
                    log::error!("{}", error);
                    error_exit();
                })
                .map(|config| async {
                    attempt_deploy_on_match(&matches).map(|use_case| {
                        start_domain_service(use_case, &config);
                    });
                    callback(config)
                })
                .ok();
        })
        .ok();
}
