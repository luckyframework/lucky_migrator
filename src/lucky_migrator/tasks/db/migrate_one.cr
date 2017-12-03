require "colorize"

class Db::MigrateOne < LuckyCli::Task
  banner "Migrate the database"

  def call
    begin
      LuckyMigrator::Runner.new.run_next_migration
    rescue e : PQ::PQError
      puts e.message.colorize(:red)
    end
  end
end
