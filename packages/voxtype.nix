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
      avx2 = "3462262980e5a75391ffdeb7d3b63f9f638d6261df042f04f9119dfb7aab7770";
      avx512 = "6a23ccf9da9e6c6eaff4b23086cea4f97cab53b12526ec88200344d597dea305";
      vulkan = "102a7caa22facc5c257c526ae4a9e63c04c027297fec4ca370209a1f94ae9863";
    }
    .${variant};
  isVulkan = variant == "vulkan";
in
stdenv.mkDerivation rec {
  pname = "voxtype";
  version = "1.1.1";

  src = fetchurl {
    url = "https://github.com/peteonrails/voxtype/releases/download/v${version}/voxtype-${version}-linux-x86_64-${variant}";
    inherit sha256;
  };

  osdSrc = fetchurl {
    url = "https://github.com/peteonrails/voxtype/releases/download/v${version}/voxtype-${version}-linux-x86_64-osd";
    sha256 = "e490fa797f39fd4f518149be851909f1d76059bf57949510ec4c24eb54d3a998";
  };

  osdGtk4Src = fetchurl {
    url = "https://github.com/peteonrails/voxtype/releases/download/v${version}/voxtype-${version}-linux-x86_64-osd-gtk4";
    sha256 = "e16f96dcf046b9cfa895541bacb73053708f3edefa8d245a2b423b288cd5a0f0";
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
