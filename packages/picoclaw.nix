{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule rec {
  pname = "picoclaw";
  version = "0.2.8";

  src = fetchFromGitHub {
    owner = "sipeed";
    repo = "picoclaw";
    rev = "v${version}";
    hash = lib.fakeHash;
  };

  vendorHash = lib.fakeHash;

  subPackages = [ "cmd/picoclaw" ];
  tags = [ "goolm" "stdjson" "whatsapp_native" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/sipeed/picoclaw/pkg/config.Version=v${version}"
    "-X github.com/sipeed/picoclaw/pkg/config.GitCommit=6e1fab80"
    "-X github.com/sipeed/picoclaw/pkg/config.BuildTime=2026-05-03T23:28:32+0000"
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
