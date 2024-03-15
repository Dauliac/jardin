#![feature(result_flattening)]
#![allow(clippy::option_map_unit_fn)]

use application::start;
use tokio::main;

pub mod application;
pub mod domain;
pub mod infrastructure;
pub mod user_interface;

#[main]
async fn main() {
    start().await;
}
