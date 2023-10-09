let
  unstableTarball =
    fetchTarball https://github.com/nixos/nixpkgs/archive/nixpkgs-unstable.tar.gz;
  pkgs = import <nixpkgs> {};
  unstable = import unstableTarball {};
  llvm = unstable.llvmPackages_16;

  shell = pkgs.mkShell {
    shellHook = ''
      export PATH=$HOME/opt/bin:$HOME/dev/binaryen/bin:$PATH;
      export ZSTD=${pkgs.zstd.out};
      export ZLIB=${pkgs.zlib.out};
    '';
    hardeningDisable = [ "all" ];
    buildInputs = [
      llvm.lldb
      llvm.bintools
      pkgs.cmake
      pkgs.ninja
      pkgs.gdb
      pkgs.tracy
      pkgs.nasm
      pkgs.s3cmd
      pkgs.rr
      pkgs.xz
      pkgs.hyperfine
      pkgs.p7zip
      pkgs.zlib
      pkgs.zstd
      pkgs.openssl
      unstable.wasmtime
    ];
  };
in shell
