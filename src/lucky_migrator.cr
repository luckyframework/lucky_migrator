require "db"
require "pg"
require "uuid"
require "lucky_cli"
require "lucky_record"
require "lucky_inflector"
require "./lucky_migrator/*"
require "./lucky_migrator/tasks/**"

module LuckyMigrator
  def self.run
    yield
  rescue e : PQ::PQError
    raise e.message.colorize(:red).to_s
  rescue e : Exception
    raise e.message.to_s
  end
end
