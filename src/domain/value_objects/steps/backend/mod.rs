use self::nix::Nix;

pub mod nix;

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum Backend {
    Nix(Nix),
}

impl Backend {
    pub fn get_nix() -> Backend {
        Backend::Nix(Nix {})
    }
}
