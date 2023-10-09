let
  rust_overlay = import (builtins.fetchTarball
    "https://github.com/oxalica/rust-overlay/archive/master.tar.gz");
  nixpkgs = import (fetchTarball https://github.com/nixos/nixpkgs/archive/nixpkgs-unstable.tar.gz) { overlays = [ rust_overlay ]; };
  rust_channel = nixpkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain;
in with nixpkgs;
pkgs.mkShell {
  shellHook = ''
    export PATH=$HOME/opt/bin:$PATH;
  '';
  nativeBuildInputs = [
    rust_channel
    nodePackages.npm
    yarn
    llvmPackages.bintools-unwrapped
    wasmtime
    wasm-pack
    wabt
    python3
    bison
    cmake
  ];
}
