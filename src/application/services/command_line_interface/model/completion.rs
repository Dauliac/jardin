// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use std::io;

use clap::{ArgMatches, Command};
use clap_complete::{generate, Generator, Shell};
use flexi_logger::FlexiLoggerError;

use crate::application::services::{
    command_line_interface::presenter::{build_cli, CliError},
    logger::{
        init_logger,
        types::{ApplicationLoggerType, LoggerType},
    },
};

fn logger_print_completion() -> Result<(), FlexiLoggerError> {
    init_logger(
        false,
        &LoggerType::Application(ApplicationLoggerType::Completion),
    )
    .map(|logger| {
        log::error!("Generate completion script ...");
        logger
    })
}

fn print_completions<G: Generator>(gen: G, cmd: &mut Command) {
    generate(gen, cmd, cmd.get_name().to_string(), &mut io::stdout());
}

pub fn attempt_generate_completion_on_match(matches: &ArgMatches) -> Result<Option<()>, CliError> {
    matches
        .get_one::<Shell>("shell")
        .map(|generator| {
            logger_print_completion()
                .map(|_ok| build_cli())
                .map(|mut cli| {
                    print_completions(*generator, &mut cli);
                })
        })
        .map_or(Ok(None), |result| {
            result.map(|_ok| Some(())).map_err(CliError::Logger)
        })
}
