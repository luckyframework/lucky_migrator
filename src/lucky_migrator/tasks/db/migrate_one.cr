require "colorize"

class Db::Migrate::One < LuckyCli::Task
  banner "Run the next pending migration"

  def call
    LuckyMigrator.run do
      LuckyMigrator::Runner.new.run_next_migration
    end
  end
end
