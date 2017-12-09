require "colorize"

class Db::Drop < LuckyCli::Task
  banner "Drop the database"

  def call
    LuckyMigrator.run do
      LuckyMigrator::Runner.drop_db
      puts "Done dropping #{LuckyMigrator::Runner.db_name.colorize(:green)}"
    end
  end
end
