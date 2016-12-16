# migrate.cr

A crystal library that can be used to create/drop/migrate/rollback your database

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  migrate.cr:
    github: paulcsmith/migrate.cr
```

## Creating, dropping and migrating the database

This library consists of various tasks that can be run from the command line.

```bash
crystal lib/migrate.cr/tasks/db/create.cr name_of_db
crystal lib/migrate.cr/tasks/db/drop.cr name_of_db
crystal lib/migrate.cr/tasks/db/migrate.cr name_of_db
crystal lib/migrate.cr/tasks/db/rollback.cr name_of_db
crystal lib/migrate.cr/tasks/db/rollback_all.cr name_of_db
```

## Generating a migration

```bash
crystal lib/migrate.cr/tasks/gen/migration.cr CreateUsers
```

This will create a timestamped migration in `db/migrations`

## Contributing

1. Fork it ( https://github.com/paulcsmith/migrate.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [paulcsmith](https://github.com/paulcsmith) Paul Smith - creator, maintainer
