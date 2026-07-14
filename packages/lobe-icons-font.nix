# AI provider glyphs (Unicode Plane 15) from github.com/hschne/lobe-icons-font.
# The release artifact is vendored to keep the package available offline.
{ stdenvNoCC }:

stdenvNoCC.mkDerivation {
  pname = "lobe-icons-font";
  version = "5.13.0";

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
