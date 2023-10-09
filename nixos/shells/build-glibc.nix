{ pkgs ? import <nixpkgs> {}, buildInputs ? [], shellHook ? "", ... }@attrs:
let
  rest = builtins.removeAttrs attrs ["pkgs" "buildInputs" "shellHook"];
  extraBuildInputs = buildInputs;
  localBuildInputs = [
    pkgs.python3
    pkgs.subversion
    pkgs.gawk
    pkgs.autoreconfHook
    pkgs.flex
    pkgs.bison
    pkgs.texinfo
  ];
  extraShellHook = shellHook;
in pkgs.stdenv.mkDerivation (rec {
  name = "glibc";
  hardeningDisable = [ "all" ];
  buildInputs = localBuildInputs ++ extraBuildInputs;
  shellHook = extraShellHook;
} // rest)
