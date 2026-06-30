# Prebuilt voxtype binary (the upstream flake compiles Rust + whisper.cpp from
# source on every build, which is far too expensive). This mirrors the AUR
# `voxtype-bin` approach: fetch a released, CPU-optimized binary and patch it
# for NixOS.
#
# variant:
#   "avx2"   - x86-64-v3 (AVX2 + FMA). Good CPU performance, works anywhere.
#   "avx512" - AVX-512 build for CPUs that support it.
#   "vulkan" - offloads Whisper to a Vulkan GPU. Needs hardware.graphics on the
#              host (for the ICD); its loader + vulkaninfo are wrapped in here so
#              nothing leaks into the system package list.
{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, alsa-lib
, curl
, openssl
, zlib
, wtype
, wl-clipboard
, ydotool
, libnotify
, playerctl
, vulkan-loader
, vulkan-tools
, variant ? "avx2"
}:

let
  sha256 = {
    avx2 = "18ae0510d0c964689f8c9b7119c0b9a45569985e82977dc4f1ef4d76fddd887c";
    avx512 = "bdb7c11fd10c33c1581d8d62352af9e4e1fd2b8dac7e4a35aa4f2775fa2ddb68";
    vulkan = "64626d07f3aae2825ddb82ea66878f708c8a820a3fd3ece76d99ff98477f132d";
  }.${variant};
  isVulkan = variant == "vulkan";
in
stdenv.mkDerivation rec {
  pname = "voxtype";
  version = "0.7.5";

  src = fetchurl {
    url = "https://github.com/peteonrails/voxtype/releases/download/v${version}/voxtype-${version}-linux-x86_64-${variant}";
    inherit sha256;
  };

  dontUnpack = true;

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = [ alsa-lib curl openssl zlib stdenv.cc.cc.lib ]
    ++ lib.optional isVulkan vulkan-loader;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/voxtype
    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/voxtype \
      --prefix PATH : ${lib.makeBinPath (
        [ wtype wl-clipboard ydotool libnotify playerctl ]
        ++ lib.optional isVulkan vulkan-tools
      )} \
      ${lib.optionalString isVulkan
        "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ vulkan-loader ]}"}
  '';

  meta = with lib; {
    description = "Push-to-talk voice-to-text for Linux (prebuilt ${variant} binary)";
    homepage = "https://voxtype.io";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "voxtype";
  };
}
