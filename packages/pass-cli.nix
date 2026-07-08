{
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

stdenv.mkDerivation rec {
  pname = "pass-cli";
  version = "2.2.2";

  src = fetchurl {
    url = "https://proton.me/download/pass-cli/${version}/pass-cli-linux-x86_64";
    hash = "sha256-Zb91GVv9D+jZZgFEyDdGa37pGV045W41V9XuZDnF91E=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];

  installPhase = ''
    install -Dm755 $src $out/bin/pass-cli
  '';
}
