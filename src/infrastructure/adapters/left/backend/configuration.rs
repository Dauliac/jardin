// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use std::path::PathBuf;

use crate::application::services::config::model::Config;

pub struct BackendConfiguration {
    version: String,
    path: PathBuf,
    config: Config,
}