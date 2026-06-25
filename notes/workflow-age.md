Just use [agencrypt](https://github.com/0x0003/scripts/blob/master/agencrypt) and [agedit](https://github.com/0x0003/scripts/blob/master/agedit)

---

- Encrypt
```fish
age -a -r (age-keygen -y ~/.config/age/keys.txt) -o home/encrypted_dot_<path>.age < file.md
```

- Decrypt
```fish
age -d -i ~/.config/age/keys.txt ~/.local/share/chezmoi/home/encrypted_dot_<path>.age
```

> [!NOTE]
> `chezmoi edit` handles files with encrypted_ prefix automatically.

