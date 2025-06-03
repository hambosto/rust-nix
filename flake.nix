{
  description = "Rust nightly toolchain for Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, rust-overlay, ... }:
    {
      homeManagerModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.programs.rust-nix;

          # Apply rust-overlay to pkgs
          rustPkgs = import nixpkgs {
            inherit (pkgs) system;
            overlays = [ rust-overlay.overlays.default ];
          };
        in
        {
          options.programs.rust-nix = with lib; {
            enable = mkEnableOption "Enable Rust nightly toolchain";

            toolchain = mkOption {
              type = types.listOf types.str;
              default = [ "rust-src" ];
              description = ''
                List of Rust toolchain components to include.
                Available: cargo, clippy, rust-docs, rust-src, rust-std, 
                rustc, rustfmt, rust-analyzer, miri
              '';
            };

            targets = mkOption {
              type = types.listOf types.str;
              default = [ "x86_64-unknown-linux-gnu" ];
              description = ''
                List of target platforms for cross-compilation.
                Examples: x86_64-unknown-linux-gnu, aarch64-unknown-linux-gnu,
                wasm32-unknown-unknown, x86_64-pc-windows-gnu
              '';
            };

            channel = mkOption {
              type = types.enum [
                "nightly"
                "beta"
                "stable"
              ];
              default = "nightly";
              description = "Rust release channel";
            };

            date = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = ''
                Specific date for nightly/beta builds (YYYY-MM-DD).
                If null, uses latest available.
              '';
              example = "2024-01-15";
            };

            fromRustupToolchain = mkOption {
              type = types.nullOr types.path;
              default = null;
              description = ''
                Path to rust-toolchain.toml file.
                When set, other options are ignored.
              '';
            };
          };

          config = lib.mkIf cfg.enable (
            let
              toolchain =
                if cfg.fromRustupToolchain != null then
                  rustPkgs.rust-bin.fromRustupToolchainFile cfg.fromRustupToolchain
                else if cfg.channel == "nightly" then
                  if cfg.date != null then
                    rustPkgs.rust-bin.nightly.${cfg.date}.default.override {
                      extensions = cfg.toolchain;
                      targets = cfg.targets;
                    }
                  else
                    rustPkgs.rust-bin.selectLatestNightlyWith (
                      toolchain:
                      toolchain.default.override {
                        extensions = cfg.toolchain;
                        targets = cfg.targets;
                      }
                    )
                else if cfg.channel == "beta" then
                  if cfg.date != null then
                    rustPkgs.rust-bin.beta.${cfg.date}.default.override {
                      extensions = cfg.toolchain;
                      targets = cfg.targets;
                    }
                  else
                    rustPkgs.rust-bin.beta.latest.default.override {
                      extensions = cfg.toolchain;
                      targets = cfg.targets;
                    }
                else
                  rustPkgs.rust-bin.stable.latest.default.override {
                    extensions = cfg.toolchain;
                    targets = cfg.targets;
                  };
            in
            {
              home.packages = [ toolchain ];
            }
          );
        };
    };
}
