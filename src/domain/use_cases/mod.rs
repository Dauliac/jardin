use self::deploy_use_case::UserStory as DeployUserStory;

pub mod deploy_use_case;

#[derive(Debug)]
pub enum UseCases {
    Deploy(DeployUserStory),
    Development,
}
