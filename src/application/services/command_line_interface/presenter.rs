use std::path::PathBuf;

use clap::value_parser;
use clap::Arg;
use clap::Command;
use clap_complete::Shell;
use flexi_logger::FlexiLoggerError;
use thiserror::Error;

use super::super::config::error::ConfigError;
use crate::application::services::config::parser::get_get_default_config_path;
use crate::application::AUTHOR;
use crate::application::NAME;
use crate::application::VERSION;

#[derive(Error, Debug)]
pub enum CliError {
    #[error("Configuration error")]
    Config(ConfigError),
    #[error("Logger error")]
    Logger(FlexiLoggerError),
}

pub const DEPLOY_COMMAND_NAME: &str = "deploy";
pub const DEVELOPMENT_COMMAND_NAME: &str = "development";
pub const DEPLOY_ARG_DEVELOPMENT: &str = DEVELOPMENT_COMMAND_NAME;
pub const DEPLOY_ARG_DRY_RUN: &str = "dry-run";

pub(crate) fn build_cli() -> Command {
    Command::new(NAME)
        .about(format!("{} 🌻, a fast and foss cluster manager", NAME))
        .author(AUTHOR)
        .version(VERSION)
        .arg_required_else_help(true)
        .arg(
            Arg::new("config")
                .short('c')
                .help(format!(
                    "TOML configuration file path, defaults is:\n {}",
                    get_get_default_config_path()
                        .unwrap_or(PathBuf::new())
                        .to_str()
                        .unwrap()
                ))
                .long("configuration"),
        )
        .arg(
            Arg::new("shell")
                .long("complete")
                .value_parser(value_parser!(Shell)),
        )
        .subcommand(
            Command::new(DEPLOY_COMMAND_NAME)
                .about("Deploy the cluster")
                .arg(
                    Arg::new(DEPLOY_ARG_DRY_RUN)
                        .short('s')
                        .help("Resolve pipeline steps without executing them"),
                )
                .arg(
                    Arg::new(DEPLOY_ARG_DEVELOPMENT)
                        .short('d')
                        .num_args(0..=1)
                        .default_value("false")
                        .default_missing_value("true")
                        .require_equals(true)
                        .value_parser(value_parser!(bool))
                        .long("dev")
                        .help(format!(
                            "Deploy the cluster on managed {} environment",
                            DEPLOY_ARG_DEVELOPMENT
                        )),
                )
                .arg(
                    Arg::new("debug")
                        .num_args(0..=1)
                        .default_value("false")
                        .default_missing_value("true")
                        .require_equals(true)
                        .value_parser(value_parser!(bool))
                        .short('D')
                        .help("Enable debug mode"),
                ),
        )
        .subcommand(
            Command::new(DEVELOPMENT_COMMAND_NAME)
                .alias("dev")
                .about(format!(
                    "Run the managed {} cluster fake for development",
                    DEVELOPMENT_COMMAND_NAME
                )),
        )
}
