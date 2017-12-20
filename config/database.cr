database = "lucky_migrator_dev"

LuckyRecord::Repo.configure do
  settings.url = ENV["DATABASE_URL"]? || LuckyRecord::PostgresURL.build(
    hostname: "localhost",
    database: database
  )
end

LuckyMigrator::Runner.configure do
  settings.database = database
end
