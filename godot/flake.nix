{
  inputs = {
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
    flake-compat,
  }:
    utils.lib.eachSystem ["aarch64-linux" "x86_64-linux"] (
      system: let
        # TODO: Change to the name of the godot project.
        project-name = "godot-project";

        pkgs = import nixpkgs {inherit system;};
        inherit (pkgs) lib stdenv;
        commonNativeBuildInputs = with pkgs; [
          pkg-config
        ];

        godot-version = pkgs.godot-headless.version;
        export-templates = let
          unpatched = pkgs.fetchzip {
            url = "https://downloads.tuxfamily.org/godotengine/${godot-version}/Godot_v${godot-version}-stable_export_templates.tpz";
            extension = "zip";
            hash = "sha256-NG6TmfWiEBirvdrCs6mlb27mIp6sjdzvSyw4jyYvkCA=";
          };
        in
          pkgs.stdenv.mkDerivation {
            pname = "godot-export-templates";
            version = godot-version;
            buildInputs = with pkgs; [
              autoPatchelfHook
              xorg.libXcursor
              xorg.libXinerama
              xorg.libXext
              xorg.libXrandr
              xorg.libXi
              libglvnd
            ];
            dontUnpack = true;
            installPhase = ''
              cp -r ${unpatched} $out
            '';
          };
      in rec {
        defaultPackage = packages.linux64;

        packages.linux64 = with pkgs;
          stdenv.mkDerivation {
            name = "linux64";
            src = ./.;
            buildInputs = [
              godot-headless
            ];
            phases = ["buildPhase"];
            buildPhase = ''
              mkdir -p "$TMP/.config"
              mkdir -p "$TMP/.local/share/godot/templates"
              mkdir -p "$TMP/.config/godot/projects/"
              export HOME=$TMP
              export XDG_CONFIG_HOME="$TMP/.config"
              export XDG_DATA_HOME="$TMP/.local/share"
              ln -s ${export-templates} "$TMP/.local/share/godot/templates/${godot-version}.stable"

              cp -r $src $TMP/src
              chmod -R u+w -- "$TMP/src"
              mkdir -p "$TMP/src/build/linux"
              godot-headless -v --path "$TMP/src" --export "Linux/X11" build/linux/${project-name}.x86_64
              mv $TMP/src/build $out
            '';
            dontStrip = true;
          };

        packages.windows64 = with pkgs;
          stdenv.mkDerivation {
            name = "windows64";
            src = ./.;
            buildInputs = [
              godot-headless
            ];
            phases = ["buildPhase"];
            buildPhase = ''
              mkdir -p "$TMP/.config"
              mkdir -p "$TMP/.local/share/godot/templates"
              mkdir -p "$TMP/.config/godot/projects/"
              export HOME=$TMP
              export XDG_CONFIG_HOME="$TMP/.config"
              export XDG_DATA_HOME="$TMP/.local/share"
              ln -s ${export-templates} "$TMP/.local/share/godot/templates/${godot-version}.stable"

              cp -r $src $TMP/src
              chmod -R u+w -- "$TMP/src"
              mkdir -p "$TMP/src/build/windows"
              godot-headless -v --path "$TMP/src" --export "Windows Desktop" build/windows/${project-name}.exe
              mv $TMP/src/build $out
            '';
            dontStrip = true;
          };

        packages.web = with pkgs;
          stdenv.mkDerivation {
            name = "web";
            src = ./.;
            buildInputs = [
              godot-headless
            ];
            phases = ["buildPhase"];
            buildPhase = ''
              mkdir -p "$TMP/.config"
              mkdir -p "$TMP/.local/share/godot/templates"
              mkdir -p "$TMP/.config/godot/projects/"
              export HOME=$TMP
              export XDG_CONFIG_HOME="$TMP/.config"
              export XDG_DATA_HOME="$TMP/.local/share"
              ln -s ${export-templates} "$TMP/.local/share/godot/templates/${godot-version}.stable"

              cp -r $src $TMP/src
              chmod -R u+w -- "$TMP/src"
              mkdir -p "$TMP/src/build/web"
              godot-headless -v --path "$TMP/src" --export "HTML5" build/web/index.html
              mv $TMP/src/build/web $out
            '';
            dontStrip = true;
          };

        devShell = with pkgs;
          mkShell {
            buildInputs = [
              godot-headless
            ];
            nativeBuildInputs = commonNativeBuildInputs;
            shellHook = ''
              ln -s ${export-templates} "$HOME/.local/share/godot/templates/${godot-version}.stable"
            '';
          };
      }
    );
}
