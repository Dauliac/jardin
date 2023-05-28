// SPDX-License-Identifier: AGPL-3.0-or-later

pub enum FinalState {
    Success(),
    Failure(),
}

pub enum Status {
    ToDo(),
    Doing(),
    Done(FinalState),
}
