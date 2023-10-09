let
  unstableTarball =
    fetchTarball https://github.com/nixos/nixpkgs/archive/nixpkgs-unstable.tar.gz;
  pkgs = import <nixpkgs> {};
  unstable = import unstableTarball {};
  llvmPackages = pkgs.llvmPackages_14;

  shell = pkgs.mkShell {
    shellHook = ''
      export PATH=$HOME/opt/bin:$PATH;
      export CC="/home/kubkon/dev/zig-bootstrap/out/zig-x86_64-linux-musl-baseline/bin/zig cc -target x86_64-linux-musl -mcpu=baseline";
      export CXX="/home/kubkon/dev/zig-bootstrap/out/zig-x86_64-linux-musl-baseline/bin/zig c++ -target x86_64-linux-musl -mcpu=baseline";
    '';
    hardeningDisable = [ "all" ];
    buildInputs = [
      pkgs.cmake
      pkgs.ninja
      pkgs.gdb
      pkgs.tracy
      pkgs.libxml2
      pkgs.nasm
      pkgs.s3cmd
      pkgs.rr
      pkgs.busybox
      pkgs.hyperfine
      pkgs.p7zip
      unstable.wasmtime
      pkgs.glibc.static
    ] ++ (with llvmPackages; [
      clang
      clang-unwrapped
      lld
      llvm
      lldb
      bintools-unwrapped
    ]);
  };
in shell
