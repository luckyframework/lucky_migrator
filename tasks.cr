# Used for testing in development

require "lucky_cli"
require "./src/lucky_migrator"
require "./db/migrations/**"
<<<<<<< 1cacfa958cbb9e05a95c11d83ba6cd13db5d9a52

database = "lucky_migrator_dev"

LuckyRecord::Repo.configure do
  if ENV["DATABASE_URL"]?
    settings.url = ENV["DATABASE_URL"]
  else
    settings.url = LuckyRecord::PostgresURL.build(
      hostname: "localhost",
      database: database
    )
  end
end

LuckyMigrator::Runner.configure do
  settings.database = database
end
=======
require "./config/database"
>>>>>>> Move database and lucky_record configuration to config folder

LuckyCli::Runner.run
