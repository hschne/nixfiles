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
    rev = "2375707477d8e9228d93216d73ada548cd3415cc";
    hash = "sha256-YVheQdZu6n2Y8056yx/XzSG9BEwtpwBRHWMPYEu1i8A=";
  };

  proxyVendor = true;
  vendorHash = "sha256-YdF4h7iL5IcWSancyCrpVXnbVzR1ygXfFTFAsA87EME=";

  subPackages = [ "cmd/picoclaw" ];
  tags = [ "goolm" "stdjson" "whatsapp_native" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/sipeed/picoclaw/pkg/config.Version=${version}"
    "-X github.com/sipeed/picoclaw/pkg/config.GitCommit=2375707"
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
