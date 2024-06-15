use crate::application::command_line_interface::presenter::CliError;
use clap::ArgMatches;

pub fn attempt_help_display_on_match(matches: &ArgMatches) -> Result<(), CliError> {
    let _sub = matches.subcommand();
    Ok(())
}
