{
  inputs = {
    naersk = {
      url = "github:nix-community/naersk/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    naersk,
  }:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        naersk-lib = pkgs.callPackage naersk {};
      in {
        defaultPackage = naersk-lib.buildPackage {
          src = ./.;
          buildInputs = with pkgs; [pkg-config openssl];
        };

        defaultApp = utils.lib.mkApp {drv = self.defaultPackage."${system}";};

        devShell = with pkgs;
          mkShell {
            buildInputs = [
              # rust
              cargo
              cargo-watch
              rustc
              rust-analyzer
              rustfmt
              rustPackages.clippy

              # system
              pkg-config
              openssl
              cmake
            ];
            RUST_LOG = "info";
            RUST_SRC_PATH = rustPlatform.rustLibSrc;
          };
      }
    );
}