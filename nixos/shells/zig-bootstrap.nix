let
  unstableTarball =
    fetchTarball https://github.com/nixos/nixpkgs/archive/nixpkgs-unstable.tar.gz;
  pkgs = import <nixpkgs> {};
  unstable = import unstableTarball {};
  llvmPackages = pkgs.llvmPackages_14;

  shell = pkgs.mkShell {
    shellHook = ''
      export PATH=$HOME/opt/bin:$PATH;
      export CMAKE_GENERATOR=Ninja;
    '';
    hardeningDisable = [ "all" ];
    buildInputs = [
      pkgs.cmake
      pkgs.gdb
      pkgs.qemu_full
      pkgs.tracy
      pkgs.libxml2
      pkgs.nasm
      pkgs.python3
      pkgs.s3cmd
      pkgs.p7zip
      pkgs.rr
      pkgs.busybox
      pkgs.hyperfine
      pkgs.ninja
      unstable.wasmtime
    ] ++ (with llvmPackages; [
      clang
      clang-unwrapped
      lld
      llvm
      bintools-unwrapped
    ]);
  };
in shell
