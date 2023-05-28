// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::domain::services::default_pipeline::default_identifier::DefaultIdentifier;

pub struct BootstrapOperatingSystemsIdentifier {}

impl DefaultIdentifier for BootstrapOperatingSystemsIdentifier {
    const VALUE: &'static str = "bootstrap_operating_systems";
}
