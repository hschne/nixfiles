{
  appimageTools,
  fetchurl,
  lib,
}:

let
  pname = "tldraw-offline";
  version = "1.11.0";

  src = fetchurl {
    url = "https://github.com/tldraw/tldraw-offline/releases/download/v${version}/tldraw-offline-linux-x86_64.AppImage";
    hash = "sha256-CUkGdHYz22gOYV5X+yAdB4yWi1Ii5zHJ53qgdnNEDgU=";
  };

  contents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${contents}/@tldesktop.desktop \
      $out/share/applications/tldraw-offline.desktop
    substituteInPlace $out/share/applications/tldraw-offline.desktop \
      --replace-fail "Exec=AppRun" "Exec=tldraw-offline"
    cp -r ${contents}/usr/share/icons $out/share/
  '';

  meta = {
    description = "Local whiteboard for people and coding agents";
    homepage = "https://github.com/tldraw/tldraw-offline";
    license = lib.licenses.unfree;
    mainProgram = "tldraw-offline";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
