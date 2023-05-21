pub enum FinalState {
    Success(),
    Failure(),
}

pub enum Status {
    ToDo(),
    Doing(),
    Done(FinalState),
}
