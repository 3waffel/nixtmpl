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
      csharp = {
        path = ./csharp;
        description = "A basic Csharp setup";
      };
      rust = {
        path = ./rust;
        description = "A basic rust setup";
      };
      godot3 = {
        path = ./godot3;
        description = "A generic godot3 ci template";
      };
    };
    templates.default = self.templates.devshell;
  };
}
