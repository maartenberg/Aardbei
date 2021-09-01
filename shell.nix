let
  sources = import ./nix/sources.nix {};
  pkgs = import sources.nixpkgs {};

  gems = pkgs.bundlerEnv {
    name = "aardbei-gems";
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset = ./gemset.nix;
  };

in pkgs.mkShell {
  packages = [
    gems
    pkgs.haskellPackages.dotenv
  ];
}
