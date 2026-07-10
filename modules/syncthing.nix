{ ... }:
{
  services.syncthing = {
    enable = true;
    user = "hschne";
    dataDir = "/home/hschne";
    configDir = "/home/hschne/.config/syncthing";
    openDefaultPorts = true;
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      devices = {
        "Diskstation" = {
          id = "U3N7BXQ-F5YKRMY-OCEL7QA-27X4OHS-IQGG2HT-PFS76US-PZF64Z7-CDGPLAW";
        };
      };
      # Folders are defined per-host (see hosts/<name>/default.nix).
    };
  };
}
