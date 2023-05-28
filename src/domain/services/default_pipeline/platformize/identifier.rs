// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::domain::services::default_pipeline::default_identifier::DefaultIdentifier;

pub struct PlatformizeIdentifier {}

impl DefaultIdentifier for PlatformizeIdentifier {
    const VALUE: &'static str = "platformize";
}
