- Dry run with diff
```sh
chezmoi apply -n -v
```

- Sync from source
```sh
chezmoi apply
```

- Sync back to source after editing a live file directly
> [!NOTE]
> Files generated from templates are ignored!
```sh
chezmoi re-add # all changed files
chezmoi re-add .config/somefile # target only
```

- Add a new file
```sh
chezmoi add ~/.config/someapp/settings.toml
```

- Add and encrypt a new file
```sh
chezmoi add --encrypt ~/.config/someapp/secret.toml
```

- Edit a managed file
```sh
chezmoi edit --watch ~/.config/someapp/settings.toml
```

- Regenerate config from init template (pulls latest + re-runs .chezmoi.toml.tmpl)
```sh
chezmoi update --init
```

- Preview and apply pending changes
```sh
chezmoi diff
```

- Stop managing a file
```sh
chezmoi forget ~/.config/someapp/settings.toml
```

- Remove a managed file entirely
```sh
chezmoi remove ~/.config/someapp/settings.toml
```

