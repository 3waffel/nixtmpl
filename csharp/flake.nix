{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    devshell,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlays.default
          ];
        };
        dependencies = with pkgs; [mono]; # Input the build dependencies here
        packageName = throw "InsertPackageName";
      in {
        packages.exe = pkgs.stdenv.mkDerivation {
          name = "exe";
          src = ./src;
          buildInputs = dependencies;
          buildPhase = ''
            chmod +x main.cs
            mcs main.cs -out:exe
          '';
          installPhase = ''
            mkdir -p $out/bin
            cp exe $out/bin
          '';
        };

        packages.${packageName} = pkgs.stdenv.mkDerivation {
          pname = packageName;
          version = "0.0.1";
          src = ./.;
          inputsFrom = [self.packages.${system}.exe];
          buildInputs = [pkgs.makeWrapper self.packages.${system}.exe];
          buildPhase = ''
            mkdir -p $out/bin
            echo "#!/usr/bin/env sh
            ${pkgs.mono}/bin/mono ${self.packages.${system}.exe}/bin/exe" > $out/bin/${packageName}
          '';
          installPhase = "chmod +x $out/bin/${packageName}";
          postInstall = ''
            wrapProgram $out/bin/${packageName} \
            --prefix PATH : ${pkgs.lib.getBin pkgs.mono}/bin \
                             ${pkgs.lib.getBin self.packages.${system}.exe}/bin
          '';
        };

        packages.default = self.packages.${system}.${packageName};

        devShells.default = pkgs.devshell.mkShell {
          packages = with pkgs; [
            alejandra
            mono
            omnisharp-roslyn
            treefmt
          ];
        };
      }
    );
}
