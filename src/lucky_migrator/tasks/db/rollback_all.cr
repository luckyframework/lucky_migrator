require "colorize"

class Db::RollbackAll < LuckyCli::Task
  banner "Rollback all migrations"

  def call
    LuckyMigrator.run do
      LuckyMigrator::Runner.new.rollback_all
      puts "Done rolling back all migrations".colorize(:green)
    end
  end
end
