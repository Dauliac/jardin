use crate::domain::models::{
    entities::{
        job::{get_none_post_check_jobs, get_none_pre_check_jobs, Job, JobIdentifier},
        step::{NextSteps, Step, StepIdentifier},
    },
    value_objects::pipeline::steps::backend,
};

const BOOTSTRAP_OPERATING_SYSTEMS_IDENTIFIER: &str = "configureDomainNameService";
const JOB_IDENTIFIER: &str = "configureDomainNameService";

fn get_step_identifier() -> StepIdentifier {
    StepIdentifier {
        value: BOOTSTRAP_OPERATING_SYSTEMS_IDENTIFIER.to_string(),
    }
}

fn get_job_identifier() -> JobIdentifier {
    JobIdentifier {
        value: JOB_IDENTIFIER.to_string(),
    }
}

pub(in crate::domain) fn get_bootstrap_operating_systems_step(nexts: NextSteps) -> Step {
    let step_identifier = get_step_identifier();
    let backend = backend::Backend::get_nix();
    let job = Job::default(get_job_identifier(), backend);

    let pre_check = get_none_pre_check_jobs();
    let post_check = get_none_post_check_jobs();
    let next = nexts;

    Step::new_starter(step_identifier, job, pre_check, post_check, next)
}
