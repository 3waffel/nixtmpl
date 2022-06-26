{
  description = "Wafu's flake templates";

  outputs = {
    self,
    nixpkgs,
  }: {
    templates = {
      rust = {
        path = ./rust;
        description = "A basic rust setup";
      };
      godot = {
        path = ./godot;
        description = "A generic godot ci template";
      };
    };
  };
}
