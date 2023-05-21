use crate::domain::services::default_pipeline::default_identifier::DefaultIdentifier;

pub struct BootstrapOperatingSystemsIdentifier {}

impl DefaultIdentifier for BootstrapOperatingSystemsIdentifier {
    const VALUE: &'static str = "bootstrap_operating_systems";
}
