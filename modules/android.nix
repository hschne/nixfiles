{ pkgs, ... }:
let
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    platformVersions = [ "34" "35" "36" ];
    buildToolsVersions = [ "35.0.0" "36.0.0" ];
    includeEmulator = true;
    includeSystemImages = true;
    systemImageTypes = [ "google_apis" ];
    abiVersions = [ "x86_64" ];
    includeNDK = true;
    ndkVersions = [ "27.0.12077973" "27.1.12297006" ];
    cmakeVersions = [ "3.22.1" ];
  };

  androidSdk = androidComposition.androidsdk;
  sdkRoot = "${androidSdk}/libexec/android-sdk";
in
{
  nixpkgs.config.android_sdk.accept_license = true;

  environment.systemPackages = [
    androidSdk
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
