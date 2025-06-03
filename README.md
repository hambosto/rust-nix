# Rust Nix Home Manager Module

Simple Home Manager module for Rust nightly toolchain with flexible configuration.

## Usage

### 1. Add to your Home Manager flake

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-nix.url = "github:hambosto/rust-nix";
  };

  outputs = { nixpkgs, home-manager, rust-nightly, ... }: {
    homeConfigurations."username" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        rust-nightly.homeManagerModules.default
        {
          programs.rust-nix = {
            enable = true;
            toolchain = [
              "cargo"
              "clippy"
              "rust-docs"
              "rust-src"
              "rust-std"
              "rustc"
              "rustfmt"
              "rust-analyzer"
            ];
            targets = [ "x86_64-unknown-linux-gnu" ];
          };
        }
      ];
    };
  };
}
```

### 2. Configuration Examples

#### Basic setup
```nix
programs.rust-nix = {
  enable = true;
  # Uses default: just rust-src component
};
```

#### Default profile toolchain (for example)
```nix
programs.rust-nix = {
  enable = true;
  toolchain = [
    "cargo"
    "clippy"
    "rust-docs"
    "rust-src"
    "rust-std"
    "rustc"
    "rustfmt"
    "rust-analyzer"
  ];
  targets = [ "x86_64-unknown-linux-gnu" ];
};
```

#### Cross-compilation ready
```nix
programs.rust-nix = {
  enable = true;
  targets = [
    "x86_64-unknown-linux-gnu"
    "aarch64-unknown-linux-gnu"
    "wasm32-unknown-unknown"
  ];
};
```

#### Specific nightly date
```nix
programs.rust-nix = {
  enable = true;
  date = "2024-01-15";
};
```

#### Beta or stable channel
```nix
programs.rust-nix = {
  enable = true;
  channel = "beta";  # or "stable"
};
```

#### Using rust-toolchain.toml
```nix
programs.rust-nix = {
  enable = true;
  fromRustupToolchain = ./rust-toolchain.toml;
};
```

## Options

- `enable` - Enable the module
- `toolchain` - List of components (default: just "rust-src")
- `targets` - Target platforms (default: current platform)  
- `channel` - "nightly", "beta", or "stable" (default: "nightly")
- `date` - Specific date for nightly/beta (default: latest)
- `fromRustupToolchain` - Path to rust-toolchain file (overrides other options)