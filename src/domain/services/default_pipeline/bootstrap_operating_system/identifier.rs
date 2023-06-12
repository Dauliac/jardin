// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use crate::domain::models::entities::{job::JobIdentifier, step::StepIdentifier};

const BOOTSTRAP_OPERATING_SYSTEMS_IDENTIFIER: &str = "bootstrap_operating_systems";
const JOB_IDENTIFIER: &str = "nix-infect";

pub(crate) fn get_step_identifier() -> StepIdentifier {
    StepIdentifier {
        value: BOOTSTRAP_OPERATING_SYSTEMS_IDENTIFIER.to_string(),
    }
}

pub(crate) fn get_job_identifier() -> JobIdentifier {
    JobIdentifier {
        value: JOB_IDENTIFIER.to_string(),
    }
}
