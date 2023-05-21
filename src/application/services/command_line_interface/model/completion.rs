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
    .and_then(|logger| {
        log::error!("Generate completion script ...");
        Ok(logger)
    })
    .or_else(|error| Err(error))
}

fn print_completions<G: Generator>(gen: G, cmd: &mut Command) {
    generate(gen, cmd, cmd.get_name().to_string(), &mut io::stdout());
}

pub fn attempt_generate_completion_on_match(matches: &ArgMatches) -> Result<Option<()>, CliError> {
    matches
        .get_one::<Shell>("shell")
        .and_then(|generator| {
            Some(
                logger_print_completion()
                    .and_then(|_ok| Ok(build_cli()))
                    .and_then(|mut cli| {
                        print_completions(generator.clone(), &mut cli);
                        Ok(())
                    }),
            )
        })
        .map_or(Ok(None), |result| {
            result
                .map(|_ok| Some(()))
                .map_err(|error| CliError::Logger(error))
        })
}
