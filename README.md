Dotfiles managed by [chezmoi](https://www.chezmoi.io/).

Secrets encrypted with [age](https://age-encryption.org/).

![screenshot](https://github.com/user-attachments/assets/6b27cbe1-0126-480a-8efa-b6a44073c87e)

## Bootstrap

One-liners below pull the `chezmoi` binary, clone this repo into `~/.local/share/chezmoi`, attempt to bootstrap Nix (Linux) or Scoop (Windows), install software (including `chezmoi` itself), apply configuration, then remove the bootstrap binary (no longer needed once chezmoi is installed by a package manager).

### Linux
> [!NOTE]
> Setting up Nix daemon requires root. Set `run_home_manager: false` in `home/.chezmoidata/config.yaml` to skip.
```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --purge-binary 0x0003
```

### Windows
```ps1
iex "&{ $(irm 'https://get.chezmoi.io/ps1') } -- init --apply --purge-binary 0x0003"
```

> Run with the `--exclude=encrypted` argument to skip encrypted files.

## Structure

Source tree showing only things of interest, dotfiles aren't shown.
```
home/
├── .chezmoiroot                    # sets this directory as $HOME
├── .chezmoi.toml.tmpl              # init-time config (encryption, mode, identity)
├── .chezmoiignore.tmpl             # OS filtering + git submodule exclusions
├── .chezmoidata/
│   ├── config.yaml                 # flags for internal use
│   └── pkgs/windows.yaml           # scoop packages
├── secrets/                        # inline age stubs (not managed)
├── dot_config/
│   ├── submodule_nvim/             # git submodule (not managed)
│   ├── symlink_nvim.tmpl           # creates a symlink referencing the submodule above
│   ├── submodule_vim/              # ^
│   ├── symlink_vim.tmpl            # ^
│   ├── submodule_home-manager/     # ^
│   └── symlink_home-manager.tmpl   # ^
├── submodule_scripts/              # ^
├── symlink_scripts.tmpl            # ^
├── submodule_ahk/                  # ^
├── symlink_ahk.tmpl                # ^
└── .chezmoiscripts/                # bootstrap scripts
    ├── linux/
    │   └── run_once_before_01-bootstrap-home-manager.sh.tmpl
    └── windows/
        └── run_once_before_01-bootstrap-install-scoop.ps1.tmpl
```

## Git submodules

| Source dir                           | Symlink template                       | Target                   |
|--------------------------------------|----------------------------------------|--------------------------|
| `/dot_config/submodule_nvim`         | `dot_config/symlink_nvim.tmpl`         | `~/.config/nvim`         |
| `/dot_config/submodule_vim`          | `dot_config/symlink_vim.tmpl`          | `~/.config/vim`          |
| `/dot_config/submodule_home-manager` | `dot_config/symlink_home-manager.tmpl` | `~/.config/home-manager` |
| `/submodule_scripts`                 | `symlink_scripts.tmpl`                 | `~/scripts`              |
| `/submodule_ahk`                     | `symlink_ahk.tmpl`                     | `~/ahk`                  |

The symlink templates contain just the source path, e.g. `{{ .chezmoi.sourceDir }}/dot_config/submodule_nvim`. Each target path gets an entry in `.chezmoiignore.tmpl` so chezmoi doesn't descend into the symlink.

## Secrets

Chezmoi looks for age key at `~/.config/age/dots-key.txt`.

- **Whole-file** (`encrypted_` prefix): auto-decrypts on apply. Encrypt with:
  ```sh
  age -a -r "$(age-keygen -y ~/.config/age/dots-key.txt)" \
    -o home/encrypted_dot_<path>.age <plaintext>
  ```
- **Inline** (`home/secrets/*.age`): stubs consumed in templates via `{{ decrypt (include "secrets/<name>.age" | trim) }}`. Encrypt the same way but output to `home/secrets/<name>.age`.

---

### Extra notes for myself for things I tend to forget

- [workflow-chezmoi](notes/workflow-chezmoi.md)
- [workflow-age](notes/workflow-age.md)
- [workflow-submodules](notes/workflow-submodules.md)

