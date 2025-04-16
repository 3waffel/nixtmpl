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
    with flake-utils.lib;
      eachSystem allSystems (system: let
        pkgs = import nixpkgs {inherit system;};
        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-full latexmk;
        };
      in rec {
        packages = rec {
          document = pkgs.stdenv.mkDerivation {
            name = "document-build";
            buildInputs = [tex];
            src = ./.;
            buildPhase = ''
              export TEXMFHOME="$(mktemp -d)"
              export TEXMFVAR="$TEXMFHOME/texmf-var/"
              export SOURCE_DATE_EPOCH="${toString self.lastModified}"

              mkdir -p $out;
              mkdir -p "$TEXMFVAR"
              latexmk -lualatex main.tex;
              cp main.pdf $out
            '';
          };
          default = packages.document;
        };
      });
}
