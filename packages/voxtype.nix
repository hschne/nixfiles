# Prebuilt voxtype binary (upstream compiles Rust + whisper.cpp from source
# on every build). Variants: avx2 (any x86-64-v3 CPU), avx512, vulkan (GPU
# offload; needs hardware.graphics on the host for the ICD).
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook4,
  alsa-lib,
  curl,
  openssl,
  zlib,
  wtype,
  wl-clipboard,
  ydotool,
  libnotify,
  playerctl,
  vulkan-loader,
  vulkan-tools,
  gtk4-layer-shell,
  variant ? "avx2",
}:

let
  sha256 =
    {
      avx2 = "18ae0510d0c964689f8c9b7119c0b9a45569985e82977dc4f1ef4d76fddd887c";
      avx512 = "bdb7c11fd10c33c1581d8d62352af9e4e1fd2b8dac7e4a35aa4f2775fa2ddb68";
      vulkan = "64626d07f3aae2825ddb82ea66878f708c8a820a3fd3ece76d99ff98477f132d";
    }
    .${variant};
  isVulkan = variant == "vulkan";
in
stdenv.mkDerivation rec {
  pname = "voxtype";
  version = "0.7.5";

  src = fetchurl {
    url = "https://github.com/peteonrails/voxtype/releases/download/v${version}/voxtype-${version}-linux-x86_64-${variant}";
    inherit sha256;
  };

  osdSrc = fetchurl {
    url = "https://github.com/peteonrails/voxtype/releases/download/v${version}/voxtype-${version}-linux-x86_64-osd";
    sha256 = "c510388dff6a69b59055a1915830fee8e0cb5aafd8f065e3e382b78a84eebab7";
  };

  osdGtk4Src = fetchurl {
    url = "https://github.com/peteonrails/voxtype/releases/download/v${version}/voxtype-${version}-linux-x86_64-osd-gtk4";
    sha256 = "fed81695551cee95bb0fd376ec6dc49638b0fd714480504d78aa597b006a5952";
  };

  dontUnpack = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook4
  ];
  buildInputs = [
    alsa-lib
    curl
    openssl
    zlib
    stdenv.cc.cc.lib
    gtk4-layer-shell
  ]
  ++ lib.optional isVulkan vulkan-loader;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/voxtype
    install -Dm755 $osdSrc $out/bin/voxtype-osd
    install -Dm755 $osdGtk4Src $out/bin/voxtype-osd-gtk4
    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/voxtype \
      --prefix PATH : "$out/bin:${
        lib.makeBinPath (
          [
            wtype
            wl-clipboard
            ydotool
            libnotify
            playerctl
          ]
          ++ lib.optional isVulkan vulkan-tools
        )
      }}" \
      ${lib.optionalString isVulkan "--prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [ vulkan-loader ]
      }"}
  '';

  meta = with lib; {
    description = "Push-to-talk voice-to-text for Linux (prebuilt ${variant} binary)";
    homepage = "https://voxtype.io";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "voxtype";
  };
}
