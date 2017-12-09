require "colorize"

class Db::Migrate < LuckyCli::Task
  banner "Migrate the database"

  def call
    LuckyMigrator.run do
      LuckyMigrator::Runner.new.run_pending_migrations
    end
  end
end
