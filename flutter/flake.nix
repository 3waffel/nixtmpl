{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          android_sdk.accept_license = true;
          allowUnfree = true;
        };
      };
      androidSdk = pkgs.androidenv.androidPkgs.tools;
    in {
      devShell = with pkgs;
        mkShell rec {
          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
          buildInputs = [
            flutter
            androidSdk
            jdk
          ];
        };
    });
}
