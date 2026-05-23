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
    rev = "eeda3aa0cd10b2873e0139adea8a677c136d1427";
    hash = "sha256-ENOw0igABhlUytMjCwH2lyVeV/2GIP9G+dRy65MatE4=";
  };

  proxyVendor = true;
  vendorHash = "sha256-YdF4h7iL5IcWSancyCrpVXnbVzR1ygXfFTFAsA87EME=";

  subPackages = [ "cmd/picoclaw" ];
  tags = [ "goolm" "stdjson" "whatsapp_native" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/sipeed/picoclaw/pkg/config.Version=${version}"
    "-X github.com/sipeed/picoclaw/pkg/config.GitCommit=eeda3aa"
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
