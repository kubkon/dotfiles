with import <nixpkgs> {};

let
  llvm = pkgs.llvmPackages;
in stdenv.mkDerivation {
  name = "zld";
  hardeningDisable = [ "all" ];
  buildInputs = [
    llvm.lldb
    llvm.bintools
    gdb
    tracy
    nasm
    rr
    hyperfine
    glibc
    glibc.static
  ];
  shellHook = ''
    export PATH=$HOME/opt/bin:$PATH
  '';

}

