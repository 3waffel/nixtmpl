{
  inputs = {
    naersk = {
      url = "github:nix-community/naersk/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    naersk,
    fenix,
    flake-compat,
  }:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        lib = pkgs.lib;
        # Use stable toolchain
        # naersk-lib = pkgs.callPackage naersk {};

        # Use nightly toolchain
        rust-nightly = fenix.packages.${system};
        naersk-lib = let
          toolchain = with rust-nightly;
            combine (with minimal; [
              cargo
              rustc
            ]);
        in
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
          src = ./.;
          inherit nativeBuildInputs buildInputs;
        };

        apps.default = utils.lib.mkApp {drv = packages.default;};

        devShells.default = with pkgs;
          mkShell {
            # Use stable toolchain
            # buildInputs = [
            #   # rust
            #   cargo
            #   rustc
            #   cargo-watch
            #   rust-analyzer
            #   rustfmt
            #   rustPackages.clippy
            # ] ++ nativeBuildInputs ++ buildInputs;

            # Use nightly toolchain
            buildInputs =
              lib.singleton (with rust-nightly;
                combine (with default; [
                  cargo
                  rustc
                  rust-std
                  clippy-preview
                  latest.rust-src
                ]))
              ++ (with pkgs; [
                rust-nightly.rust-analyzer
                cargo-expand
              ])
              ++ nativeBuildInputs
              ++ buildInputs;

            shellHook = ''
              export PATH=$HOME/.cargo/bin:$PATH
            '';
            RUST_LOG = "info";
            RUST_SRC_PATH = rustPlatform.rustLibSrc;
          };
      }
    );
}
