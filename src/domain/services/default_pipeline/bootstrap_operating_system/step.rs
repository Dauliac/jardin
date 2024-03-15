use crate::domain::models::{
    entities::{
        job::{get_none_post_check_jobs, get_none_pre_check_jobs, Job},
        step::{NextSteps, Step},
    },
    value_objects::pipeline::steps::backend,
};

use super::identifier::{get_job_identifier, get_step_identifier};

pub(in crate::domain) fn get_bootstrap_operating_systems_step(nexts: NextSteps) -> Step {
    let step_identifier = get_step_identifier();
    let backend = backend::Backend::get_nix();
    let job = Job::default(get_job_identifier(), backend);

    let pre_check = get_none_pre_check_jobs();
    let post_check = get_none_post_check_jobs();
    let next = nexts;

    Step::new_starter(step_identifier, job, pre_check, post_check, next)
}
