{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule rec {
  pname = "picoclaw";
  version = "0.2.8-unstable-2026-05-22";

  src = fetchFromGitHub {
    owner = "hschne";
    repo = "picoclaw";
    rev = "d94d2cad5935711222e4464ea44cc9b46d97c0f5";
    hash = "sha256-t3yByichvSEnFUVcSwm54GwLOcAc7wSvH21+eH31+J8=";
  };

  proxyVendor = true;
  vendorHash = "sha256-BqjxAeWvoUh234x9yfodqscMq+QaUQHCyGSX1y1Ywwg=";

  subPackages = [ "cmd/picoclaw" ];
  tags = [ "goolm" "stdjson" "whatsapp_native" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/sipeed/picoclaw/pkg/config.Version=${version}"
    "-X github.com/sipeed/picoclaw/pkg/config.GitCommit=d94d2ca"
    "-X github.com/sipeed/picoclaw/pkg/config.BuildTime=2026-05-22T00:00:00+0000"
    "-X github.com/sipeed/picoclaw/pkg/config.GoVersion=unknown"
  ];

  preBuild = ''
    go generate ./...
  '';

  env = {
    CGO_ENABLED = 0;
    GOTOOLCHAIN = "local";
  };

  meta = {
    description = "Tiny, fast personal automation assistant with native WhatsApp support";
    homepage = "https://github.com/sipeed/picoclaw";
    license = lib.licenses.mit;
    mainProgram = "picoclaw";
    platforms = lib.platforms.linux;
  };
}
