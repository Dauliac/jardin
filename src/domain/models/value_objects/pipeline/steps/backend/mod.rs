// SPDX-FileCopyrightText: 2023 AGPL-3.0-or-later

use serde::{Deserialize, Serialize};

use self::nix::Nix;

pub mod nix;

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, Eq, Hash)]
pub enum Backend {
    Nix(Nix),
}

impl Backend {
    pub fn get_nix() -> Backend {
        Backend::Nix(Nix {})
    }
}
