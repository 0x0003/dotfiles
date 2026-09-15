- Add a new submodule
```sh
cd ~/.local/share/chezmoi
git submodule add <url> home/dot_config/submodule_<name>
```

- Add a symlink template so chezmoi creates the symlink on apply
```sh
cat > home/dot_config/symlink_<name>.tmpl <<'EOF'
{{ .chezmoi.sourceDir }}/dot_config/submodule_<name>
EOF
```

- Add the **REAL** target path (e.g. `.config/submodule_nvim`, NOT `dot_config/submodule_nvim`) to `home/.chezmoiignore.tmpl` so chezmoi doesn't descend into the symlinked directory
```
.config/<name>
```

