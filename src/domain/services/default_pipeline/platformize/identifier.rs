use crate::domain::services::default_pipeline::default_identifier::DefaultIdentifier;

pub struct PlatformizeIdentifier {}

impl DefaultIdentifier for PlatformizeIdentifier {
    const VALUE: &'static str = "platformize";
}
