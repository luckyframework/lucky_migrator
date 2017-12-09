require "db"
require "pg"
require "lucky_cli"
require "lucky_record"
require "lucky_inflector"
require "./lucky_migrator/*"
require "./lucky_migrator/tasks/**"

module LuckyMigrator
  def self.run
    yield
  rescue e : PQ::PQError
    puts e.message.colorize(:red)
    exit(1)
  rescue e : Exception
    puts e.message
    exit(1)
  end
end
