require "colorize"

class Db::Redo < LuckyCli::Task
  banner "Rollback then run the last migration"

  def call
    begin
      LuckyMigrator::Runner.new.redo_last_migration
    rescue e : PQ::PQError
      puts e.message.colorize(:red)
    end
  end
end
