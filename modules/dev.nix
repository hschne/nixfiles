{ pkgs, ... }:
{
  # Toolchain and libraries for compiling software and language runtimes.
  # openssl and sqlite are here as build/runtime deps for mise-compiled
  # runtimes (Ruby, Python, ...), not as general-purpose packages.
  environment.systemPackages = with pkgs; [
    gcc
    gnumake
    pkg-config
    openssl
    sqlite
  ];
}
