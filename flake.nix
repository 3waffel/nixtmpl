{
  outputs = {self}: let
    pathMapper = builtins.map (
      path: let
        flake = import "${path}/flake.nix";
        description =
          if builtins.hasAttr "description" flake
          then flake.description
          else "(no description)";
      in {
        name = builtins.baseNameOf path;
        value = {inherit path description;};
      }
    );
    mkTemplates = paths: builtins.listToAttrs (pathMapper paths);
  in {
    templates =
      {default = self.templates.minimal;}
      // mkTemplates [
        ./csharp
        ./devshell
        ./flutter
        ./godot3
        ./latex
        ./minimal
        ./rust
      ];
  };
}
