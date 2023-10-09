let
  unstableTarball =
    fetchTarball https://github.com/nixos/nixpkgs/archive/nixpkgs-unstable.tar.gz;
  pkgs = import <nixpkgs> {};
  unstable = import unstableTarball {};
  llvm = unstable.llvmPackages_15;

  shell = pkgs.mkShell {
    shellHook = ''
      export PATH=$HOME/opt/bin:$PATH;
    '';
    hardeningDisable = [ "all" ];
    buildInputs = [
      llvm.lldb
      llvm.bintools
      pkgs.libxml2
      pkgs.ncurses
      pkgs.bluez
      pkgs.cmake
      pkgs.ninja
      pkgs.gdb
      pkgs.qemu_full
      pkgs.tracy
      pkgs.nasm
      pkgs.python3
      pkgs.rr
      pkgs.xz
      pkgs.hyperfine
      pkgs.openssl
    ];
  };
in shell
