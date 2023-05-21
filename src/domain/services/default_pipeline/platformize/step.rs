use crate::domain::services::default_pipeline::default_identifier::DefaultIdentifier;
use crate::domain::value_objects::steps::backend;
use crate::domain::value_objects::steps::job::{
    get_none_post_check_jobs, get_none_pre_check_jobs, Job,
};
use crate::domain::value_objects::steps::step::{NextSteps, Step};

use super::identifier::PlatformizeIdentifier;

pub fn get_platformize_step(next: fn() -> NextSteps) -> Step {
    const JOB_IDENTIFIER: &'static str = "platformize";
    let step_identifier = PlatformizeIdentifier::VALUE.to_string();
    let backend = backend::Backend::get_nix();
    let job = Job::new(JOB_IDENTIFIER.to_string(), backend);

    let pre_check = get_none_pre_check_jobs();
    let post_check = get_none_post_check_jobs();
    let next = next();
    Step::new_starter(step_identifier, job, pre_check, post_check, next)
}
