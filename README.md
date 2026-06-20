Dotfiles managed by [chezmoi](https://www.chezmoi.io/).

Secrets are handled by [pass](https://www.passwordstore.org/).

![screenshot](https://github.com/user-attachments/assets/6b27cbe1-0126-480a-8efa-b6a44073c87e)

## Bootstrap

```sh
chezmoi init --apply 0x0003
```

## Workflow

```sh
# Add a new file
chezmoi add ~/.config/someapp/settings.toml

# Edit a managed file
chezmoi edit ~/.config/someapp/settings.toml

# After editing the live file directly, sync back to source
chezmoi re-add ~/.config/someapp/settings.toml

# Dry run
chezmoi apply -n -v

# Preview and apply pending changes
chezmoi diff
chezmoi apply

# Stop managing a file
chezmoi forget ~/.config/someapp/settings.toml

# Remove a managed file entirely
chezmoi remove ~/.config/someapp/settings.toml
```

