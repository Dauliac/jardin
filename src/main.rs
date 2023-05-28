// SPDX-License-Identifier: AGPL-3.0-or-later

use application::start;
use tokio::main;

pub mod application;
pub mod domain;
pub mod infrastructure;

#[main]
async fn main() {
    start();
}
