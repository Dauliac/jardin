// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

pub mod model;
pub mod presenter;

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

pub fn start_cli(
    config_service: impl Fn(Option<&String>) -> Result<Config, ConfigError>,
) -> Result<Config, CliError> {
    // TODO rewrite in functional style
    let matches = build_cli().get_matches();
    attempt_help_display_on_match(&matches)?;
    attempt_generate_completion_on_match(&matches)?;
    let config = read_config(&matches, config_service)?;
    if let Some(use_case) = attempt_deploy_on_match(&matches) {
        start_domain_service(use_case, &config)
    }
    Ok(config)
}
