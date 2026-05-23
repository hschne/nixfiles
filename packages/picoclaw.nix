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
    rev = "ebf2cd4a083bed31a12b8504542142d72c5fe4ab";
    hash = "sha256-+msSDHAEnX0DgmRZDYVaqi0EOxEpuwTrZlsXIXwdV/g=";
  };

  proxyVendor = true;
  vendorHash = "sha256-YdF4h7iL5IcWSancyCrpVXnbVzR1ygXfFTFAsA87EME=";

  subPackages = [ "cmd/picoclaw" ];
  tags = [ "goolm" "stdjson" "whatsapp_native" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/sipeed/picoclaw/pkg/config.Version=${version}"
    "-X github.com/sipeed/picoclaw/pkg/config.GitCommit=ebf2cd4"
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
