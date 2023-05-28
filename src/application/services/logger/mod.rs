// SPDX-License-Identifier: AGPL-3.0-or-later

use flexi_logger::{FlexiLoggerError, Logger};

use self::{
    application::{
        logger_formatter_command_line_interface, logger_formatter_completion,
        logger_formatter_config, logger_formatter_deployment,
    },
    types::LoggerType,
};

pub mod application;
pub mod domain;
pub mod formatter;
pub mod types;

pub fn init_logger(debug_logs: bool, logger_type: &LoggerType) -> Result<(), FlexiLoggerError> {
    let logger_formatter = match &logger_type {
        LoggerType::Application(logger) => match logger {
            types::ApplicationLoggerType::Config => logger_formatter_config,
            types::ApplicationLoggerType::Completion => logger_formatter_completion,
            types::ApplicationLoggerType::CommandLineInterface => {
                logger_formatter_command_line_interface
            }
            types::ApplicationLoggerType::Deployment => logger_formatter_deployment,
        },
        LoggerType::Domain(_) => todo!(),
    };
    Logger::try_with_env_or_str(match debug_logs {
        true => "debug",
        false => "info",
    })?
    .format(logger_formatter)
    .set_palette("196;208;51;7;8".to_string())
    .start()
    .map(|_| ())
}
