// SPDX-License-Identifier: AGPL-3.0-or-later

use flexi_logger::{DeferredNow, Record, TS_DASHES_BLANK_COLONS_DOT_BLANK};

use super::types::LoggerType;

const fn make_emoji(level: log::Level) -> &'static str {
    match level {
        log::Level::Error => "❌",
        log::Level::Warn => "⚠️",
        log::Level::Info => "ℹ️",
        log::Level::Debug => "❓",
        log::Level::Trace => "🖊️",
    }
}

pub fn logger_formatter_scoped(
    write: &mut dyn std::io::Write,
    now: &mut DeferredNow,
    logger_type: &LoggerType,
    record: &Record,
) -> Result<(), std::io::Error> {
    let level: log::Level = record.level();

    write!(
        write,
        "[{} {}] {} [{}] {}",
        make_emoji(level),
        level.as_str().to_uppercase(),
        now.format(TS_DASHES_BLANK_COLONS_DOT_BLANK),
        logger_type,
        record.args()
    )
}

pub fn logger_formatter(
    write: &mut dyn std::io::Write,
    now: &mut DeferredNow,
    record: &Record,
) -> Result<(), std::io::Error> {
    let level: log::Level = record.level();

    write!(
        write,
        "[{} {}] {} {}",
        make_emoji(level),
        level.as_str().to_uppercase(),
        now.format(TS_DASHES_BLANK_COLONS_DOT_BLANK),
        record.args()
    )
}
