# MongoDB

## Backup y Restore
- Backup:
```sh
mongodump --db database

# Para transferirlo:
tar -cvzf dump.tar.gz dump_folder
scp meshdump.tar.gz <user>@<ip>:/path
```

- Restore:
```sh
mongorestore --verbose archivo

# Opcional:
# --drop (borra la db existente)

# A otra db
mongorestore --db database --verbose archivo
```