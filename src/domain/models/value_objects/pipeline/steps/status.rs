// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, PartialEq)]
pub enum FinalState {
    Success(),
    Failure(),
}

#[derive(Serialize, Deserialize, Clone, PartialEq)]
pub enum Status {
    ToDo(),
    Doing(),
    Done(FinalState),
}
