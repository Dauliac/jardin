// SPDX-License-Identifier: AGPL-3.0-or-later

use flexi_logger::{DeferredNow, Record};

use super::formatter::{logger_formatter, logger_formatter_scoped};

pub fn logger_formatter_config(
    write: &mut dyn std::io::Write,
    now: &mut DeferredNow,
    record: &Record,
) -> Result<(), std::io::Error> {
    logger_formatter(write, now, record)
}

pub fn logger_formatter_completion(
    write: &mut dyn std::io::Write,
    now: &mut DeferredNow,
    record: &Record,
) -> Result<(), std::io::Error> {
    logger_formatter_scoped(
        write,
        now,
        &super::types::LoggerType::Application(super::types::ApplicationLoggerType::Completion),
        record,
    )
}

pub fn logger_formatter_command_line_interface(
    write: &mut dyn std::io::Write,
    now: &mut DeferredNow,
    record: &Record,
) -> Result<(), std::io::Error> {
    logger_formatter(write, now, record)
}

pub fn logger_formatter_deployment(
    write: &mut dyn std::io::Write,
    now: &mut DeferredNow,
    record: &Record,
) -> Result<(), std::io::Error> {
    logger_formatter_scoped(
        write,
        now,
        &super::types::LoggerType::Application(super::types::ApplicationLoggerType::Deployment),
        record,
    )
}
