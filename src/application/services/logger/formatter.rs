 

use colored::*;

const fn make_emoji(level: log::Level) -> &'static str {
    match level {
        log::Level::Error => "❌",
        log::Level::Warn => "⚠️",
        log::Level::Info => "ℹ️",
        log::Level::Debug => "❓",
        log::Level::Trace => "🖊️",
    }
}

pub fn logger_formatter_human(
    write: &mut dyn std::io::Write,
    now: &mut DeferredNow,
    record: &Record,
) -> Result<(), std::io::Error> {
    let level: log::Level = record.level();
    write!(
        write,
        "{} {}: {}",
        make_emoji(level),
        level.as_str().to_uppercase().green().bold(),
        record.args()
    )
}
