// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use crate::domain::models::value_objects::pipeline::steps::backend;
use crate::domain::models::value_objects::pipeline::steps::job::{
    get_none_post_check_jobs, get_none_pre_check_jobs, Job,
};
use crate::domain::models::value_objects::pipeline::steps::step::{NextSteps, Step};
use crate::domain::services::default_pipeline::default_identifier::DefaultIdentifier;

use super::identifier::BootstrapOperatingSystemsIdentifier;

pub fn get_bootstrap_operating_systems_step(nexts: NextSteps) -> Step {
    const JOB_IDENTIFIER: &str = "nix-infect";
    let step_identifier = BootstrapOperatingSystemsIdentifier::VALUE.to_string();
    let backend = backend::Backend::get_nix();
    let job = Job::new(JOB_IDENTIFIER.to_string(), backend);

    let pre_check = get_none_pre_check_jobs();
    let post_check = get_none_post_check_jobs();
    let next = nexts;

    Step::new_starter(step_identifier, job, pre_check, post_check, next)
}
