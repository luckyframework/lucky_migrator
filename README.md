# migrate.cr

A crystal library that can be used to create/drop/migrate/rollback your database

## Installation

Add this to your application's `shard.yml`:

```yaml
# Remember to also install the LuckyCli to run the tasks
dependencies:
  migrate.cr:
    github: luckyframework/migrator
```

LuckyMigrator **requires installing the LuckyCli** so you can run the tasks.

See instructions at [the LuckyCli repo](https://github.com/luckyframework/cli)

```crystal
# In your tasks.cr file
# This will load all the db tasks
require "lucky_migrator"

# Then require your migrations. Typically this is in db/migrations
require "./db/migrations/*"
```

## Creating, dropping and migrating the database

This library consists of various tasks that can be run with LuckyCli

```bash
lucky db.create
lucky db.drop
lucky db.migrate
lucky db.rollback
lucky db.rollback_all
```

## Generating a migration

```bash
lucky gen.migration CreateUsers
```

This will create a timestamped migration in `db/migrations`

## Contributing

1. Fork it ( https://github.com/luckyframework/migrator/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [paulcsmith](https://github.com/paulcsmith) Paul Smith - creator, maintainer
