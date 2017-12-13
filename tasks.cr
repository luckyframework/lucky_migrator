# Used for testing in development

require "lucky_cli"
require "./src/lucky_migrator"
require "./db/migrations/**"
require "./config/database"

LuckyCli::Runner.run
