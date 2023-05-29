// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

#![cfg_attr(coverage_nightly, feature(no_coverage))]

use application::start;
use tokio::main;

pub mod application;
pub mod domain;
pub mod infrastructure;

#[main]
async fn main() {
    start();
}
