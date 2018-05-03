require "colorize"

class Db::Create < LuckyCli::Task
  banner "Create the database"

  def call
    LuckyMigrator.run do
      LuckyMigrator::Runner.create_db
    end
  end
end
