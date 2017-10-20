# Used for testing in development

require "lucky_cli"
require "./src/lucky_migrator"
require "./db/migrations/**"

database = "lucky_migrator_dev"

LuckyRecord::Repo.configure do
  settings.url = LuckyRecord::PostgresURL.build(
  hostname: "localhost",
  database: database
  )
end

LuckyMigrator::Runner.configure do
  settings.database = database
end

LuckyCli::Runner.run
