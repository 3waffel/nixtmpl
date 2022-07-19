# ❄ nixtmpl
A collection of nix flake templates.

initialize current directory
```
nix flake init -t github:3waffel/nixtmpl#rust
```
or create a new project 
```
nix flake new -t github:3waffel/nixtmpl#rust ./project
```

## Templates
### Rust
+ make sure to add `cargo.toml` and `cargo.lock` to git before building
+ set the project name in `flake.nix`

### Godot
+ `flake.nix` is assumed to be under the same directory with `project.godot`
+ set the project name in `flake.nix`
