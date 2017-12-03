require "colorize"

class Db::RollbackAll < LuckyCli::Task
  banner "Rollback all migrations"

  def call
    begin
      LuckyMigrator::Runner.new.rollback_all
      puts "Done rolling back all migrations".colorize(:green)
    rescue e : PQ::PQError
      puts e.message.colorize(:red)
      exit(1)
    end
  end
end
