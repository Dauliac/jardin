use crate::{
    application::command_line_interface::presenter::{
        DEPLOY_ARG_DRY_RUN, DEPLOY_COMMAND_NAME, DEVELOPMENT_COMMAND_NAME,
    },
    domain::use_cases::{deploy_use_case::UserStory as DeployUserStory, UseCases},
};
use clap::ArgMatches;
use std::ops::Not;

fn is_development_mode(matches: &ArgMatches) -> bool {
    *matches
        .get_one::<bool>(DEVELOPMENT_COMMAND_NAME)
        .unwrap_or(&false)
}

fn is_dry_run_mode(matches: &ArgMatches) -> bool {
    *matches
        .get_one::<bool>(DEPLOY_ARG_DRY_RUN)
        .unwrap_or(&false)
}

fn check_deploy_production(matches: &ArgMatches) -> bool {
    is_dry_run_mode(matches)
        .not()
        .then_some(is_development_mode(matches).not())
        .is_some()
}

fn check_deploy_dry_run(matches: &ArgMatches) -> bool {
    is_dry_run_mode(matches)
        .then_some(is_development_mode(matches).not())
        .is_some()
}

fn attempt_deploy_production(matches: &ArgMatches) -> Option<UseCases> {
    check_deploy_production(matches).then_some(UseCases::Deploy(
        DeployUserStory::DeployClusterToProductionWithDefaultPipeline,
    ))
}

fn attempt_deploy_dry_run(matches: &ArgMatches) -> Option<UseCases> {
    check_deploy_dry_run(matches).then_some(UseCases::Deploy(
        DeployUserStory::DeployClusterToProductionWithDefaultPipelineInDryRunMode,
    ))
}

pub fn attempt_deploy_on_match(matches: &ArgMatches) -> Option<UseCases> {
    matches
        .subcommand_matches(DEPLOY_COMMAND_NAME)
        .and_then(|matches| {
            attempt_deploy_production(matches).or_else(|| attempt_deploy_dry_run(matches))
        })
}
