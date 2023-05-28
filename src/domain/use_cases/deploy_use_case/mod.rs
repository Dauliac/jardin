// SPDX-License-Identifier: AGPL-3.0-or-later

#[derive(Debug)]
pub enum UserStory {
    DeployClusterToProductionWithDefaultPipeline,
    DeployClusterToProductionWithDefaultPipelineInDryRunMode,
    DeployClusterToDevelopWithDefaultPipeline,
    DeployClusterToDevelopWithDefaultPipelineInDryRunMode,
}
