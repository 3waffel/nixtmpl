{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane.url = "github:ipetkov/crane";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    fenix,
    crane,
    ...
  }:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            fenix.overlays.default
            (final: prev: {
              fenixToolchain = with prev.fenix;
                combine [
                  stable.clippy
                  stable.rustc
                  stable.cargo
                  stable.rustfmt
                  stable.rust-src
                  targets.wasm32-unknown-unknown.latest.rust-std
                  targets.x86_64-pc-windows-gnu.latest.rust-std
                ];
            })
          ];
        };
        _crane = (crane.mkLib pkgs).overrideToolchain pkgs.fenixToolchain;
        env = {
          LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
        };
      in rec {
        packages.default = with pkgs;
          _crane.buildPackage {
            inherit env;
            pname = "untitled";
            src = lib.cleanSource ./.;
            doCheck = false;
            buildInputs = [
              clang
              gcc.cc.lib
            ];
            nativeBuildInputs = [
              pkg-config
              rustPlatform.bindgenHook
            ];
          };
        apps.default = utils.lib.mkApp {drv = packages.default;};
        devShells.default = with pkgs;
          mkShell {
            inherit env;
            packages = [
              fenixToolchain
              cargo-watch
              rust-analyzer

              pkg-config
              clang
              gcc.cc.lib
            ];
            nativeBuildInputs = [rustPlatform.bindgenHook];
          };
      }
    );
}
