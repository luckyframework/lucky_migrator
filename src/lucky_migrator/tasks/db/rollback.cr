require "colorize"

class Db::Rollback < LuckyCli::Task
  banner "Rollback the last migration"

  def call
    LuckyMigrator.run do
      LuckyMigrator::Runner.new.rollback_one
    end
  end
end
