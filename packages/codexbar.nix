{ stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "codexbar";
  version = "0.38.0";

  src = fetchurl {
    url = "https://github.com/steipete/CodexBar/releases/download/v${version}/CodexBarCLI-v${version}-linux-musl-x86_64.tar.gz";
    hash = "sha256-VGw5BMeRhNlO/Rn9VOOadlXiAt6nvV9Sck5VubPTdek=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm755 CodexBarCLI $out/bin/CodexBarCLI
    ln -s $out/bin/CodexBarCLI $out/bin/codexbar
    install -Dm444 VERSION $out/share/codexbar/VERSION

    runHook postInstall
  '';

  meta = {
    description = "CLI for fetching CodexBar provider usage";
    homepage = "https://github.com/steipete/CodexBar";
    platforms = [ "x86_64-linux" ];
  };
}
