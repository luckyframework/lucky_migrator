require "colorize"

class Db::Migrate < LuckyCli::Task
  banner "Migrate the database"

  def call
    begin
      LuckyMigrator::Runner.new.run_pending_migrations
    rescue e : PQ::PQError
      puts e.message.colorize(:red)
      exit(1)
    end
  end
end
