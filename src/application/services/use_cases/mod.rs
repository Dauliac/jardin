use crate::domain::{
    services::default_pipeline::get_default_pipeline,
    use_cases::{deploy_use_case::UserStory as DeployUserStory, UseCases},
};

use super::config::model::Config;

pub fn deploy_cluster_to_production_with_default_pipeline(_config: &Config) {
    let pipeline = get_default_pipeline();
    println!("AAAA {:?}", pipeline)
}

pub fn deploy_cluster_to_production_with_default_pipeline_in_dry_run_mode(_config: &Config) {
    println!("BBBB")
}

pub fn deploy_cluster_to_develop_with_default_pipeline_in_dry_run_mode(_config: &Config) {
    println!("CCCC")
}

pub fn deploy_cluster_to_develop_with_default_pipeline(_config: &Config) {
    println!("DDDD")
}

pub fn handle_deploy_user_story(user_story: DeployUserStory, config: &Config) {
    match user_story {
        DeployUserStory::DeployClusterToProductionWithDefaultPipeline => {
            deploy_cluster_to_production_with_default_pipeline(config)
        }
        DeployUserStory::DeployClusterToProductionWithDefaultPipelineInDryRunMode => {
            deploy_cluster_to_production_with_default_pipeline_in_dry_run_mode(config)
        }
        DeployUserStory::DeployClusterToDevelopWithDefaultPipelineInDryRunMode => {
            deploy_cluster_to_develop_with_default_pipeline(config)
        }
        DeployUserStory::DeployClusterToDevelopWithDefaultPipeline => {
            deploy_cluster_to_develop_with_default_pipeline_in_dry_run_mode(config)
        }
    };
}

pub fn start_domain_service(use_case: UseCases, config: &Config) {
    match use_case {
        UseCases::Deploy(deploy) => handle_deploy_user_story(deploy, config),
        UseCases::Development => todo!(),
    }
}
