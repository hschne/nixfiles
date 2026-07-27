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
    install -Dm644 ${contents}/@tldesktop.desktop \
      $out/share/applications/tldraw-offline.desktop
    substituteInPlace $out/share/applications/tldraw-offline.desktop \
      --replace-fail "Exec=AppRun" "Exec=tldraw-offline" \
      --replace-fail "Icon=@tldesktop" "Icon=tldraw-offline"

    # Upstream drops these, so launcher search cannot find the app by topic
    echo "Keywords=tldraw;whiteboard;diagram;canvas;" \
      >> $out/share/applications/tldraw-offline.desktop

    # Upstream ships icons under an unsubstituted @tldesktop template placeholder
    for icon in ${contents}/usr/share/icons/hicolor/*/apps/@tldesktop.png; do
      size=$(basename $(dirname $(dirname $icon)))
      install -Dm644 "$icon" "$out/share/icons/hicolor/$size/apps/tldraw-offline.png"
    done
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
