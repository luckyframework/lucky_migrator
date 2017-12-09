require "colorize"

class Db::Create < LuckyCli::Task
  banner "Create the database"

  def call
    LuckyMigrator.run do
      LuckyMigrator::Runner.create_db
      puts "Done creating #{LuckyMigrator::Runner.db_name.colorize(:green)}"
    end
  end
end
