{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule rec {
  pname = "picoclaw";
  version = "0.2.8-unstable-2026-05-23";

  src = fetchFromGitHub {
    owner = "hschne";
    repo = "picoclaw";
    rev = "776b57741346de5d23512fcb7a1283c194f25070";
    hash = "sha256-x6vmWRAzqD/+XEDfeoJL0zSIX3PXccHkjSR5juyFf/0=";
  };

  proxyVendor = true;
  vendorHash = "sha256-BqjxAeWvoUh234x9yfodqscMq+QaUQHCyGSX1y1Ywwg=";

  subPackages = [ "cmd/picoclaw" ];
  tags = [ "goolm" "stdjson" "whatsapp_native" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/sipeed/picoclaw/pkg/config.Version=${version}"
    "-X github.com/sipeed/picoclaw/pkg/config.GitCommit=776b577"
    "-X github.com/sipeed/picoclaw/pkg/config.BuildTime=2026-05-23T00:00:00+0000"
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
