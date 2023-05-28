// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use clap::ArgMatches;

use crate::application::services::command_line_interface::presenter::CliError;

pub fn attempt_help_display_on_match(matches: &ArgMatches) -> Result<(), CliError> {
    let _sub = matches.subcommand();
    Ok(())
}
