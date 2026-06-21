- Encrypt a new whole-file secret
```fish
age -a -r (age-keygen -y ~/.config/age/dots-key.txt) -o home/encrypted_dot_<path>.age plaintext
```

- Encrypt a new inline secret stub (stored under `home/secrets/`)
```fish
age -a -r (age-keygen -y ~/.config/age/dots-key.txt) -o <path-to-chezmoi>/home/secrets/<name>.age plaintext
```

- Decrypt to verify
```fish
age -d -i ~/.config/age/dots-key.txt <path-to-chezmoi>/home/encrypted_dot_<path>.age
```

