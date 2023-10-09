with (import <nixpkgs> {}).pkgsMusl;

let
  llvm = llvmPackages;
in stdenv.mkDerivation {
  name = "zld-gcc-musl";
  hardeningDisable = [ "all" ];
  buildInputs = [
    llvm.lldb
    llvm.bintools
  ];
  shellHook = ''
    export PATH=$HOME/opt/bin:$PATH
  '';

}

