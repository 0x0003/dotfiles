<div align=center>
  <a href="https://www.chezmoi.io/">
    <img alt="Chezmoi" src="https://img.shields.io/badge/chezmoi-4051B5?style=for-the-badge&logo=HomeAdvisor&logoColor=white"/>
  </a>
  <a href="https://nixos.org/">
    <img alt="Nix" src="https://img.shields.io/badge/Nix-66ABDE?style=for-the-badge&logo=nixos&logoColor=white"/>
  </a>
  <a href="https://scoop.sh/">
    <img alt="Nix" src="https://img.shields.io/badge/Scoop-3B3B3B?style=for-the-badge&logo=iced&logoColor=white"/>
  </a>
</div>

<div align=center>
  <img alt="Linux" src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black"/>
  <img alt="Windows" src="https://custom-icon-badges.demolab.com/badge/Windows-0078D6?style=for-the-badge&logo=windows11&logoColor=white"/>
</div>

| Terminal                                                                                  | Firefox and mpv                                                                           |
| ----------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| ![term](https://github.com/user-attachments/assets/6b27cbe1-0126-480a-8efa-b6a44073c87e)  | ![ffmpv](https://github.com/user-attachments/assets/99156e5b-7ce3-49a2-b9e7-57086d1c9202) |

## Bootstrap

One-liners below pull the `chezmoi` binary, clone this repo into `~/.local/share/chezmoi`, attempt to bootstrap Nix (Linux) or Scoop (Windows), install software (including `chezmoi` itself), apply configuration, then remove the bootstrap binary (no longer needed once chezmoi is installed by a package manager).

> Run with the `--exclude=encrypted` argument to skip encrypted files.

### Linux
> [!NOTE]
> Setting up Nix daemon requires root.  
> Remove `--promptDefaults` flag and answer `false` in the prompt to skip Nix bootstrap.  
> Can later be changed by running `chezmoi edit-config`.
```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --promptDefaults --purge-binary 0x0003
```

### Windows
> [!NOTE]
> Windows needs a special setting to enable creation of symlinks (lol)  
> gpedit.msc -> Computer Configuration -> Windows Settings -> Security Settings -> Local Policies -> User Rights Assignment -> Create symbolic links -> click "Add User or Group" -> type your username -> click "Check Names" -> Apply -> REBOOT  
> Remove `--promptDefaults` flag and answer `false` in the prompt to not attempt to create symlinks on windows.  
> Can later be changed by running `chezmoi edit-config`.
```ps1
iex "&{ $(irm 'https://get.chezmoi.io/ps1') } -- init --apply --promptDefaults --purge-binary 0x0003"
```

> Windows will not purge binary, but it will echo its location to stdout at the end.

## Structure

Source tree showing only things of interest, dotfiles aren't shown.
```
home/
├── .chezmoiroot                    # sets this directory as $HOME
├── .chezmoi.toml.tmpl              # init-time config (encryption, mode, identity)
├── .chezmoiignore.tmpl             # OS filtering + git submodule exclusions
├── .chezmoidata/
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
    ├── linux
    │   ├── run_once_after_01-post-setup.sh.tmpl
    │   └── run_once_before_01-home-manager.sh.tmpl
    └── windows
        ├── run_once_after_01-configure-scoop.ps1.tmpl
        └── run_once_before_01-install-scoop.ps1.tmpl
```

## Git submodules

| Source dir                                                               | Symlink template                       | Target                   |
| ------------------------------------------------------------------------ | -------------------------------------- | ------------------------ |
| /dot_config/[submodule_nvim](https://github.com/0x0003/nvimrc)           | `dot_config/symlink_nvim.tmpl`         | `~/.config/nvim`         |
| /dot_config/[submodule_vim](https://github.com/0x0003/vimrc)             | `dot_config/symlink_vim.tmpl`          | `~/.config/vim`          |
| /dot_config/[submodule_home-manager](https://github.com/0x0003/home.nix) | `dot_config/symlink_home-manager.tmpl` | `~/.config/home-manager` |
| /[submodule_scripts](https://github.com/0x0003/scripts)                  | `/symlink_scripts.tmpl`                | `~/scripts`              |
| /[submodule_ahk](https://github.com/0x0003/ahk)                          | `/symlink_ahk.tmpl`                    | `~/ahk`                  |

The symlink templates contain just the source path, e.g. `{{ .chezmoi.sourceDir }}/dot_config/submodule_nvim`. Each target path gets an entry in `.chezmoiignore.tmpl` so chezmoi doesn't descend into the symlink.

## Secrets

Encrypted with [age](https://age-encryption.org/).

Chezmoi looks for age key at `~/.config/age/dots-key.txt`.

- **Whole-file** (`encrypted_` prefix): auto-decrypts on apply.
- **Inline** (`home/secrets/*.age`): stubs consumed in templates via `{{ decrypt (include "secrets/<name>.age") | trim -}}`.

---

### Extra notes for myself for things I tend to forget

- [workflow-chezmoi](notes/workflow-chezmoi.md)
- [workflow-age](notes/workflow-age.md)
- [workflow-submodules](notes/workflow-submodules.md)

