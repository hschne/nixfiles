{ pkgs, ... }:
let
  # Pinned to the Expo SDK 54 / React Native 0.81 toolchain used by zar-core mobile-rn.
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    platformVersions = [ "36" ];
    buildToolsVersions = [ "36.0.0" ];
    includeEmulator = true;
    includeSystemImages = true;
    systemImageTypes = [ "google_apis" ];
    abiVersions = [ "x86_64" ];
    includeNDK = true;
    ndkVersions = [ "27.1.12297006" ];
    cmakeVersions = [ "3.22.1" ];
  };

  androidSdk = androidComposition.androidsdk;
  sdkRoot = "${androidSdk}/libexec/android-sdk";
in
{
  # The SDK ships redistributable-but-unfree blobs behind a clickthrough license.
  nixpkgs.config.android_sdk.accept_license = true;

  environment.systemPackages = [
    androidSdk
    pkgs.jdk17
  ];

  environment.sessionVariables = {
    ANDROID_HOME = sdkRoot;
    ANDROID_SDK_ROOT = sdkRoot;
    JAVA_HOME = "${pkgs.jdk17}";

    # avdmanager honours XDG_CONFIG_HOME and writes AVDs to ~/.config/.android/avd,
    # but the emulator binary only ever reads ~/.android/avd — so a freshly created
    # AVD is invisible to `emulator -list-avds`. Pin both tools to the same root.
    ANDROID_USER_HOME = "$HOME/.android";

    # Gradle downloads an unpatched aapt2 from Maven that cannot run on NixOS;
    # force it to the SDK's patched binary instead.
    GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${sdkRoot}/build-tools/36.0.0/aapt2";
  };
}
