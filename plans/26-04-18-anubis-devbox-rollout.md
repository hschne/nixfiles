# Anubis devbox rollout plan

## Goal

Add terminal-only devbox tooling to `anubis` in small, low-risk NixOS steps, rebuilding and verifying after each change. Keep the repo simple for now by extending the existing shared `modules/base.nix` for Steps 1–3, and defer deeper splitting until the config earns it.

## Tasks

1. **Step 1**: Extend `modules/base.nix` with the first low-risk devbox packages and verify the rebuild path
   - File: `modules/base.nix`
   - Changes: Add safe core packages that should not require extra service setup to the existing `environment.systemPackages` list in `modules/base.nix`: `wget`, `rsync`, `unzip`, `zip`, `gzip`, `btop`, `fastfetch`, `tree`, `less`, `file`, `gnupg`, and `age`. Keep this step to plain package additions only.
   - Acceptance: On `anubis`, `sudo nixos-rebuild switch --flake ~/Source/nixfiles#anubis` succeeds and `command -v wget rsync btop fastfetch tree` all return paths.

2. **Step 2**: Extend `modules/base.nix` with shell and dotfile bootstrap support, then switch the login shell declaratively
   - File: `modules/base.nix`
   - Changes: Add `zsh`, `tmux`, `neovim`, `starship`, and `yadm` to `modules/base.nix`. Configure the shell declaratively in the same module instead of relying on manual `chsh`, e.g. enable Zsh and set the default shell for `hschne`. After the rebuild, do the non-Nix bootstrap that the old setup doc handled manually: clone dotfiles with `yadm`, create `~/Source` and `~/.env` if dotfiles do not already do that, and confirm homeshick is not involved.
   - Acceptance: Rebuild succeeds; a new login shell is Zsh for `hschne`; `command -v yadm zsh tmux nvim` works; `yadm status` works after cloning the dotfiles repo.

3. **Step 3**: Extend `modules/base.nix` again with daily terminal/dev workflow tools
   - File: `modules/base.nix`
   - Changes: Add the terminal workflow packages that are just package installs to `modules/base.nix`: `eza`, `bat`, `fd`, `ripgrep`, `fzf`, `zoxide`, `jq`, `yq`, `du-dust`, `git-delta`, `gh`, `lazygit`, `httpie`, `ctags`, and `entr`. Keep this step package-only; do not split the module yet.
   - Acceptance: Rebuild succeeds; `command -v rg fd fzf eza bat jq yq gh lazygit http` works; basic smoke tests pass such as `rg --version`, `gh --version`, and `lazygit --version`.

4. **Step 4**: Add tools that need follow-up setup and verify them one by one
   - File: `modules/base.nix`
   - File: `modules/docker.nix`
   - File: `hosts/anubis/default.nix`
   - Changes: Extend `modules/base.nix` with `mise`, `fnox`, and Proton Pass CLI if the desired nixpkgs attribute exists. Create `modules/docker.nix` for Docker so service config lives apart from the general package list; enable Docker declaratively and ensure `hschne` has the needed group membership. After the rebuild, do the old setup-file follow-up work outside Nix where appropriate: add `mise activate zsh` via dotfiles, install runtimes through `mise`, authenticate `pass-cli`, initialize `fnox`, add providers, and sync secrets.
   - Acceptance: Rebuild succeeds; `systemctl status docker` shows the daemon running; after re-login, `docker version` works for `hschne`; `command -v mise fnox` works; `mise doctor` and `fnox doctor` can run once the manual bootstrap is completed.

5. **Step 5**: Capture the non-Nix bootstrap steps and freeze the first working devbox baseline
   - File: `README.md`
   - File: `plans/26-04-18-anubis-devbox-rollout.md`
   - Changes: Update `README.md` with the minimal bring-up sequence for a fresh host: rebuild, `yadm clone`, shell re-login, `mise` runtime install, Proton Pass login, `fnox` init/sync, and Docker re-login. Keep this as a short runbook so the repo clearly distinguishes declarative NixOS config from one-time user bootstrap tasks.
   - Acceptance: A fresh session on `anubis` can follow the README steps without consulting `setup-wayland.md`, and every package or service added in Steps 1–4 is either declarative in NixOS or explicitly documented as a one-time manual bootstrap step.

## Files to Modify

- `hosts/anubis/default.nix` - import Docker if it becomes a separate module.
- `modules/base.nix` - extend the shared baseline with the terminal-only package set and shell settings.
- `modules/docker.nix` - hold Docker service config.
- `README.md` - add a short host bring-up runbook.

## New Files (if any)

- `modules/docker.nix` - Docker service and user access.

## What We're NOT Doing

- Creating a `packages/` directory or splitting `modules/base.nix` further yet.
- Introducing Home Manager.
- Porting GUI/Wayland, browser, Bluetooth, audio, or desktop software from `setup-wayland.md`.
- Encoding interactive secret login flows entirely in NixOS.
- Solving every dotfiles concern in this pass; only enough to bootstrap `anubis` cleanly.

## Risks & Edge Cases

- Some package names from the old Arch setup may differ in nixpkgs, especially Proton Pass CLI and possibly `fnox`; verify exact attributes before coding each step.
- Switching the default shell declaratively can require a fresh login before behavior matches expectations.
- Docker access usually requires both group membership and a new login session before `docker` works without `sudo`.
- Dotfiles may already create files like `~/.env`, shell activation, and `~/Source`; avoid duplicating that setup in NixOS if yadm already owns it.
- `mise`, Proton Pass, and `fnox` all include manual or interactive bootstrap steps, so command availability and full usability should be tested separately.
