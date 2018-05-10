# Symmetric Encryption with `gpg`

Encrypt stdin with passphrase in `~/secret-passphrase.txt` to `message.gpg`:

```bash
echo very secret message | gpg --symmetric --batch --passphrase-file ~/secret-passphrase.txt > message.gpg
```

Decrypt `message.gpg` to stdout with passphrase in `~/secret-passphrase.txt`:

```bash
gpg --decrypt --batch --quiet --passphrase-file ~/secret-passphrase.txt message.gpg
```

Decrypt from stdin to stdout with passphrase in `~/secret-passphrase.txt`:

```bash
cat message.gpg | gpg --decrypt --batch --quiet --passphrase-file ~/secret-passphrase.txt
```

Just for the lulz: end-to end encryption and decryption in a pipe:

```bash
echo very secret message \
  | gpg --symmetric --batch --passphrase-file ~/secret-passphrase.txt \
  | gpg --decrypt --batch --quiet --passphrase-file ~/secret-passphrase.txt
```
