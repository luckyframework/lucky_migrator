require "colorize"

class Db::Migrate < LuckyCli::Task
  banner "Migrate the database"

  def initialize(@quiet : Bool = false)
  end

  def call(args = ARGV)
    LuckyMigrator.run do
      LuckyMigrator::Runner.new(@quiet).run_pending_migrations
    end
  end
end
