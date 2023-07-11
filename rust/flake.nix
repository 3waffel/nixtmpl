{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    naersk = {
      url = "github:nix-community/naersk/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    devshell,
    naersk,
    fenix,
    ...
  }:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlays.default
            fenix.overlays.default
            (final: prev: {
              toolchain = with prev.fenix;
                combine [
                  (complete.withComponents [
                    "cargo"
                    "clippy"
                    "rust-src"
                    "rustc"
                    "rustfmt"
                  ])
                  targets.wasm32-unknown-unknown.latest.rust-std
                  targets.x86_64-pc-windows-gnu.latest.rust-std
                ];
            })
          ];
        };
        naersk-lib = with pkgs;
          naersk.lib.${system}.override {
            cargo = toolchain;
            rustc = toolchain;
          };
        nativeBuildInputs = with pkgs; [
          pkg-config
        ];
        buildInputs = with pkgs; [
          openssl
        ];
      in rec {
        packages.default = naersk-lib.buildPackage {
          pname = "untitled";
          src = ./.;
          inherit nativeBuildInputs buildInputs;
        };

        apps.default = utils.lib.mkApp {drv = packages.default;};

        devShells.default = pkgs.devshell.mkShell {
          packages = with pkgs; [
            alejandra
            direnv
            taplo-cli
            treefmt
            toolchain
          ];
        };
      }
    );
}
