{ config, lib, pkgs, ... }:

{
  services.pcscd.enable = true;
  
  environment.systemPackages = with pkgs; [
    gnupg
    yubikey-personalization
    yubico-piv-tool
  ];

  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gnome3";
  };

  environment.shellInit = ''
    gpg-connect-agent /bye
  '';

  programs.ssh = {
    startAgent = true;
    extraConfig = lib.mkBefore ''
    PKCS11Provider=${pkgs.yubico-piv-tool}/lib/libykcs11.so
    '';
  };
}
