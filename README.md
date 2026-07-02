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

| Alacritty running neovim inside tmux                                                      | Firefox and mpv                                                                           |
| ----------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| ![term](https://github.com/user-attachments/assets/6b27cbe1-0126-480a-8efa-b6a44073c87e)  | ![ffmpv](https://github.com/user-attachments/assets/99156e5b-7ce3-49a2-b9e7-57086d1c9202) |

![repo size](https://img.shields.io/endpoint?style=for-the-badge&color=8c997d&labelColor=121212&url=https%3A%2F%2Fraw.githubusercontent.com%2F0x0003%2Fdotfiles%2Fbadge-data%2Fsize.json)

## Bootstrap

One-liners below pull the chezmoi binary, `git clone --recurse-submodules` this repo into `~/.local/share/chezmoi`, bootstrap Nix (Linux) or Scoop (Windows), install software (including chezmoi itself), apply configuration, then attempt to remove the bootstrap binary.

> Run with `--exclude=encrypted` to skip encrypted files;  
> `--exclude=externals` to skip external downloads;  
> `--promptDefaults` to skip interactive init prompts.

### Linux
```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --purge-binary 0x0003
```
<details>
<summary>Init prompts</summary>
  <ul>
    <li>`has_root`: boolean; default true - whether you have sudo/root access
    <li> `use_home_manager`: boolean; default true - whether to set up home-manager (only prompted if `has_root` is true) </li>
  </ul>
</details>

### Windows
> [!NOTE]
> Windows needs a special setting to enable creation of symlinks 🙄  
> gpedit.msc -> Computer Configuration -> Windows Settings -> Security Settings -> Local Policies -> User Rights Assignment -> Create symbolic links -> click "Add User or Group" -> type your username -> click "Check Names" -> Apply -> REBOOT
>
> Windows will not purge binary, but it will echo its location to stdout at the end.
```ps1
iex "&{ $(irm 'https://get.chezmoi.io/ps1') } -- init --apply --purge-binary 0x0003"
```
<details>
<summary>Init prompts</summary>
  <ul>
    <li>`create_symlinks`: boolean; default true - whether to enable creation of symlinks (see note above)</li>
    <li>`use_scoop`: boolean; default true - whether to install packages via Scoop</li>
  </ul>
</details>

## Structure

Source tree showing only things of interest.
```
. # repo root
├── .chezmoiversion # minimum chezmoi version required to interpret the source state
├── .chezmoiroot    # sets chezmoi root to home/
└── home/
    ├── .chezmoi.toml.tmpl  # init-time config
    ├── .chezmoiignore.tmpl # OS filtering + git submodule exclusions
    ├── .chezmoiscripts/
    │   ├── linux
    │   │   ├── run_once_before_01-home-manager.sh.tmpl     # bootstrap Nix and home-manager
    │   │   ├── run_once_after_01-post-home-manager.sh.tmpl # extra root-owned system configuration
    │   │   ├── run_once_after_02-wsl-config.sh.tmpl        # populate /etc/wsl.conf
    │   │   └── run_once_after_03-wsl-dns.sh.tmpl           # create a service for wsl NAT networking
    │   └── windows
    │       ├── run_once_before_01-install-scoop.ps1.tmpl       # bootstrap scoop and add buckets
    │       ├── run_onchange_after_02-install-packages.ps1.tmpl # scoop install packages from YAML
    │       └── run_once_after_01-configure-scoop.ps1.tmpl      # scoop config
    ├── .chezmoidata/
    │   ├── pkgs/windows.yaml # scoop packages
    │   └── themes            # colorschemes, applied through templates
    ├── secrets/              # inline age stubs (not managed)
    ├── dot_config/
    │   ├── submodule_nvim/           # git submodule (not managed)
    │   ├── symlink_nvim.tmpl         # creates a symlink referencing the submodule above
    │   ├── submodule_vim/            # ^
    │   ├── symlink_vim.tmpl          # ^
    │   ├── submodule_home-manager/   # ^
    │   └── symlink_home-manager.tmpl # ^
    ├── submodule_scripts/            # ^
    ├── symlink_scripts.tmpl          # ^
    ├── submodule_ahk/                # ^
    └── symlink_ahk.tmpl              # ^
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

Chezmoi looks for [age](https://age-encryption.org/) key at `~/.config/age/keys.txt`.

- **Whole-file** (`encrypted_` prefix): auto-decrypts on apply.
- **Inline** (`home/secrets/*.age`): stubs consumed in templates via `{{ decrypt (include "secrets/<name>.age") | trim -}}`.

---

### Extra notes for myself for things I tend to forget

- [workflow-chezmoi](notes/workflow-chezmoi.md)
- [workflow-age](notes/workflow-age.md)
- [workflow-submodules](notes/workflow-submodules.md)

