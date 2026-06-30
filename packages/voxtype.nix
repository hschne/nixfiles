# Prebuilt voxtype binary (the upstream flake compiles Rust + whisper.cpp from
# source on every build, which is far too expensive). This mirrors the AUR
# `voxtype-bin` approach: fetch the released x86-64-v3/AVX2 binary and patch it
# for NixOS. Swap the asset to `-vulkan` if you want GPU Whisper on the laptop.
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
}:

stdenv.mkDerivation rec {
  pname = "voxtype";
  version = "0.7.5";

  src = fetchurl {
    url = "https://github.com/peteonrails/voxtype/releases/download/v${version}/voxtype-${version}-linux-x86_64-avx2";
    sha256 = "18ae0510d0c964689f8c9b7119c0b9a45569985e82977dc4f1ef4d76fddd887c";
  };

  dontUnpack = true;

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = [ alsa-lib curl openssl zlib stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/voxtype
    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/voxtype \
      --prefix PATH : ${lib.makeBinPath [ wtype wl-clipboard ydotool libnotify playerctl ]}
  '';

  meta = with lib; {
    description = "Push-to-talk voice-to-text for Linux (prebuilt AVX2 binary)";
    homepage = "https://voxtype.io";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "voxtype";
  };
}
