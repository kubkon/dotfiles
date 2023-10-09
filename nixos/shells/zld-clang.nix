with import <nixpkgs> {};

let
  llvm = pkgs.llvmPackages;
in llvm.stdenv.mkDerivation {
  name = "zld";
  hardeningDisable = [ "all" ];
  buildInputs = [
    llvm.lldb
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

