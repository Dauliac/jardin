use std::process;

// pub(crate) fn graceful_exit() {
//     process::exit(0);
// }

pub(crate) fn error_exit() {
    process::exit(1);
}
