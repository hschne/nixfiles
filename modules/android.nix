{ pkgs, ... }:
let
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    platformVersions = [
      "34"
      "35"
      "36"
    ];
    buildToolsVersions = [
      "35.0.0"
      "36.0.0"
    ];
    includeEmulator = true;
    includeSystemImages = true;
    systemImageTypes = [ "google_apis" ];
    abiVersions = [ "x86_64" ];
    includeNDK = true;
    ndkVersions = [
      "27.0.12077973"
      "27.1.12297006"
    ];
    cmakeVersions = [ "3.22.1" ];
  };

  androidSdk = androidComposition.androidsdk;
  sdkRoot = "${androidSdk}/libexec/android-sdk";

  # Create AVDs with dev-usable hardware; avdmanager defaults to hw.keyboard=no, which makes typing laggy.
  avdCreate = pkgs.writeShellApplication {
    name = "avd-create";
    runtimeInputs = [
      androidSdk
      pkgs.jdk17
      pkgs.coreutils
      pkgs.gnused
      pkgs.gnugrep
    ];
    text = ''
      name=''${1:-}
      api=''${2:-36}
      device=''${3:-pixel_7}

      if [ -z "$name" ]; then
        echo "usage: avd-create <name> [api-level] [device]" >&2
        exit 1
      fi

      export ANDROID_HOME=${sdkRoot}
      export ANDROID_SDK_ROOT=${sdkRoot}

      avdHome=''${ANDROID_AVD_HOME:-''${ANDROID_USER_HOME:-$HOME/.android}/avd}
      config="$avdHome/$name.avd/config.ini"

      echo no | avdmanager create avd \
        --name "$name" \
        --package "system-images;android-$api;google_apis;x86_64" \
        --device "$device"

      setProp() {
        if grep -q "^$1=" "$config"; then
          sed -i "s|^$1=.*|$1=$2|" "$config"
        else
          echo "$1=$2" >>"$config"
        fi
      }

      setProp hw.keyboard yes
      setProp hw.gpu.enabled yes
      setProp hw.gpu.mode host
      setProp hw.ramSize 4G
      setProp hw.cpu.ncore 6
      setProp vm.heapSize 512M

      echo "Created $name ($config)"
    '';
  };
in
{
  nixpkgs.config.android_sdk.accept_license = true;

  environment.systemPackages = [
    androidSdk
    avdCreate
    pkgs.jdk17
    pkgs.maestro
  ];

  environment.sessionVariables = {
    ANDROID_HOME = sdkRoot;
    ANDROID_SDK_ROOT = sdkRoot;
    JAVA_HOME = "${pkgs.jdk17}";
    ANDROID_USER_HOME = "$HOME/.android";
    GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${sdkRoot}/build-tools/36.0.0/aapt2";
  };
}
