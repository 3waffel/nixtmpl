{
  description = "Wafu's flake templates";

  outputs = {
    self,
    nixpkgs,
  }: {
    templates = {
      tauri = {
        path = ./tauri;
        description = "tauri project setup";
      };
      trivial = {
        path = ./trivial;
        description = "A basic flake setup";
      };
      csharp = {
        path = ./csharp;
        description = "A basic Csharp setup";
      };
      riff = {
        path = ./riff;
        description = "build rust project with riff";
      };
      rust = {
        path = ./rust;
        description = "A basic rust setup";
      };
      godot = {
        path = ./godot;
        description = "A generic godot ci template";
      };
    };
    templates.default = self.templates.trivial;
  };
}
