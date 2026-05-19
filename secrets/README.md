# agenix secrets

Current recipients live in `secrets.nix`.

## Encrypt the GitHub SSH key

Once `agenix` is available, create or edit the secret with:

```bash
cd ~/Source/nixfiles
agenix -e secrets/github-ssh-hschne.age -i ~/.ssh/hschne@github.com -r
```

Or set the editor and run:

```bash
cd ~/Source/nixfiles
EDITOR='cat ~/.ssh/hschne@github.com >' agenix -e secrets/github-ssh-hschne.age -r
```

## Rekey after adding recipients

After adding `anubis` or other devices to `secrets/secrets.nix`:

```bash
cd ~/Source/nixfiles
agenix -r
```
```
