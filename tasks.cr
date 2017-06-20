# Used for testing in development

require "lucky_cli"
require "./src/lucky_migrator"
require "./db/migrations/**"

LuckyMigrator::Runner.db_name = "lucky_migrator_dev"

LuckyCli::Runner.run
