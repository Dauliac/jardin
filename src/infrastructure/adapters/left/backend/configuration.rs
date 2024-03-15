use std::path::PathBuf;

use crate::application::services::config::model::Config;

pub struct BackendConfiguration {
    version: String,
    path: PathBuf,
    config: Config,
}
