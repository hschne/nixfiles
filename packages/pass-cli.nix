{ pkgs, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "pass-cli";
  version = "2.0.2";

  src = pkgs.fetchurl {
    url = "https://proton.me/download/pass-cli/${version}/pass-cli-linux-x86_64";
    hash = "sha256-/WClBB5kKnsRNe9oeMPXzjUjsIMhDqgQDu5cNwEBftk=";
  };

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = [ pkgs.stdenv.cc.cc.lib ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/pass-cli
    chmod +x $out/bin/pass-cli
  '';
}
