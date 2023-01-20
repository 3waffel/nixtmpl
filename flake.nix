{
  description = "Wafu's flake templates";

  outputs = {
    self,
    nixpkgs,
  }: {
    templates = {
      devshell = {
        path = ./devshell;
        description = "A basic flake setup with devshell";
      };
      tauri = {
        path = ./tauri;
        description = "tauri project setup";
      };
      csharp = {
        path = ./csharp;
        description = "A basic Csharp setup";
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
    templates.default = self.templates.devshell;
  };
}
