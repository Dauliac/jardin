// SPDX-License-Identifier: AGPL-3.0-or-later

use self::services::{command_line_interface::start_cli, config::parser::parse_config};

pub mod services;

pub const VERSION: &str = env!("CARGO_PKG_VERSION");
pub const NAME: &str = env!("CARGO_PKG_NAME");
pub const AUTHOR: &str = env!("CARGO_PKG_AUTHORS");

pub fn start() {
    let _config = start_cli(parse_config);
}
