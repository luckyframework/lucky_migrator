# LuckyMigrator

A crystal library that can be used to create/drop/migrate/rollback your database

## Installation

Add this to your application's `shard.yml`:

```yaml
# Remember to also install the LuckyCli to run the tasks
dependencies:
  lucky_migrator:
    github: luckyframework/lucky_migrator
```

LuckyMigrator **requires installing the LuckyCli** so you can run the tasks. See instructions at [the LuckyCli repo](https://github.com/luckyframework/cli).

#### Setup tasks in tasks.cr

```crystal
# tasks.cr file
require "lucky_cli"

# This will load all the db tasks
require "lucky_migrator"

# Require your migrations. Remember to create the directory too.
require "./db/migrations/*"

LuckyMigrator::Runner.db_name = "my_cool_db"

# This should always be at the bottom or your tasks won't be available in LuckyCli
LuckyCli::Runner.run
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

1. Fork it ( https://github.com/luckyframework/lucky_migrator/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Testing

To run the tests:

* Install Postgres: ([macOS](https://postgresapp.com)/[Others](https://wiki.postgresql.org/wiki/Detailed_installation_guides))
* Migrate the database using `lucky db.create && lucky db.migrate`
* Run the tests with `crystal spec`

## Contributors

- [paulcsmith](https://github.com/paulcsmith) Paul Smith - creator, maintainer
- [mikeeus](https://github.com/mikeeus) Mikias Abera - contributor