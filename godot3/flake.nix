{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
  }:
    utils.lib.eachSystem ["aarch64-linux" "x86_64-linux"] (
      system: let
        pkgs = import nixpkgs {inherit system;};
        inherit (pkgs) stdenv;

        # TODO: Change to the name of the godot project.
        project-name = "godot-project";
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
            dontUnpack = true;
            installPhase = ''
              cp -r ${unpatched} $out
            '';
          };
        configurePhase = ''
          mkdir -p "$TMP/.config"
          mkdir -p "$TMP/.local/share/godot/templates"
          mkdir -p "$TMP/.config/godot/projects/"
          export HOME=$TMP
          export XDG_CONFIG_HOME="$TMP/.config"
          export XDG_DATA_HOME="$TMP/.local/share"
          ln -s ${export-templates} "$TMP/.local/share/godot/templates/${godot-version}.stable"
        '';
      in rec {
        packages.default = packages.linux64;

        packages.linux64 = with pkgs;
          stdenv.mkDerivation {
            name = "linux64";
            src = ./.;
            buildInputs = [
              godot-headless
            ];
            inherit configurePhase;
            buildPhase = ''
              cp -r $src $TMP/src
              chmod -R u+w -- "$TMP/src"
              mkdir -p "$TMP/src/build/linux"
              godot-headless -v --path "$TMP/src" --export "Linux/X11" build/linux/${project-name}.x86_64
            '';
            installPhase = ''
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
            inherit configurePhase;
            buildPhase = ''
              cp -r $src $TMP/src
              chmod -R u+w -- "$TMP/src"
              mkdir -p "$TMP/src/build/windows"
              godot-headless -v --path "$TMP/src" --export "Windows Desktop" build/windows/${project-name}.exe
            '';
            installPhase = ''
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
            inherit configurePhase;
            buildPhase = ''
              cp -r $src $TMP/src
              chmod -R u+w -- "$TMP/src"
              mkdir -p "$TMP/src/build/web"
              godot-headless -v --path "$TMP/src" --export "HTML5" build/web/index.html
            '';
            installPhase = ''
              mv $TMP/src/build/web $out
            '';
            dontStrip = true;
          };

        devShells.default = with pkgs;
          mkShell {
            packages = [
              godot-headless
            ];
            inherit configurePhase;
          };
      }
    );
}
