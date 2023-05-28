// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use flexi_logger::{DeferredNow, Record};

use super::formatter::logger_formatter_scoped;

pub fn logger_formatter_step(
    write: &mut dyn std::io::Write,
    now: &mut DeferredNow,
    record: &Record,
) -> Result<(), std::io::Error> {
    logger_formatter_scoped(
        write,
        now,
        &super::types::LoggerType::Domain(super::types::DomainLoggerType::Step),
        record,
    )
}

pub fn logger_formatter_job(
    write: &mut dyn std::io::Write,
    now: &mut DeferredNow,
    record: &Record,
) -> Result<(), std::io::Error> {
    logger_formatter_scoped(
        write,
        now,
        &super::types::LoggerType::Domain(super::types::DomainLoggerType::Job),
        record,
    )
}

pub fn logger_formatter_pre_check(
    write: &mut dyn std::io::Write,
    now: &mut DeferredNow,
    record: &Record,
) -> Result<(), std::io::Error> {
    logger_formatter_scoped(
        write,
        now,
        &super::types::LoggerType::Domain(super::types::DomainLoggerType::PreCheck),
        record,
    )
}

pub fn logger_formatter_post_check(
    write: &mut dyn std::io::Write,
    now: &mut DeferredNow,
    record: &Record,
) -> Result<(), std::io::Error> {
    logger_formatter_scoped(
        write,
        now,
        &super::types::LoggerType::Domain(super::types::DomainLoggerType::PostCheck),
        record,
    )
}
