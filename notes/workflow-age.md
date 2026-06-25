Just use [agencrypt](https://github.com/0x0003/scripts/blob/master/agencrypt) and [agedit](https://github.com/0x0003/scripts/blob/master/agedit)

---

- Encrypt a new whole-file secret
```fish
age -a -r (age-keygen -y ~/.config/age/keys.txt) -o home/encrypted_dot_<path>.age < file.md
```

- Encrypt a new inline secret stub (stored under `home/secrets/`)
```fish
age -a -r (age-keygen -y ~/.config/age/keys.txt) -o ~/.local/share/chezmoi/home/secrets/<name>.age < file.md
```

- Decrypt to verify
```fish
age -d -i ~/.config/age/keys.txt ~/.local/share/chezmoi/home/encrypted_dot_<path>.age
```

