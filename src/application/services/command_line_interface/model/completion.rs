use std::io;

use clap::{ArgMatches, Command};
use clap_complete::{generate, Generator, Shell};

use crate::application::services::command_line_interface::presenter::build_cli;

fn logger_print_completion() {
    log::error!("Generate completion script ...");
}

fn print_completions<G: Generator>(gen: G, cmd: &mut Command) {
    generate(gen, cmd, cmd.get_name().to_string(), &mut io::stdout());
}

pub fn attempt_generate_completion_on_match(matches: &ArgMatches) -> bool {
    matches
        .get_one::<Shell>("shell")
        .map(|generator| {
            logger_print_completion();
            let mut cli = build_cli();
            print_completions(*generator, &mut cli);
        })
        .is_some()
}
