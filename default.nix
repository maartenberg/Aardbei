let
  sources = import ./nix/sources.nix {};
  pkgs = import sources.nixpkgs {};
in {
  inherit (pkgs) bundix bundler;
}
