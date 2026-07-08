# AI provider glyphs (Unicode Plane 15) from github.com/hschne/lobe-icons-font.
# The repo is private, so the built ttf is vendored here.
{ stdenvNoCC }:

stdenvNoCC.mkDerivation {
  pname = "lobe-icons-font";
  version = "0-unstable-2026-06-27";

  src = ./fonts/lobe-icons.ttf;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 $src $out/share/fonts/truetype/lobe-icons.ttf
    runHook postInstall
  '';

  meta = {
    description = "lobe-icons: AI provider glyphs (Unicode Plane 15)";
    homepage = "https://github.com/hschne/lobe-icons-font";
  };
}
