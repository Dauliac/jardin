// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use crate::domain::models::entities::{job::JobIdentifier, step::StepIdentifier};

const PLATFORMIZE_IDENTIFIER: &str = "platformize";
const JOB_IDENTIFIER: &str = "platformize";

pub(crate) fn get_step_identifier() -> StepIdentifier {
    StepIdentifier {
        value: PLATFORMIZE_IDENTIFIER.to_string(),
    }
}

pub(crate) fn get_job_identifier() -> JobIdentifier {
    JobIdentifier {
        value: JOB_IDENTIFIER.to_string(),
    }
}
