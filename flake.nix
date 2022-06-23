{
  description = "A very basic flake";

  outputs = { self, nixpkgs }: {
    templates = {
          rust-dev = {
            path = ./rust-dev;
            description = "A basic rust setup";
          };
        };
  };
}
