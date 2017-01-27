require "colorize"

class Db::Migrate < LuckyCli::Task
  banner "Migrate the database"

  def call
    puts "Migrating...".colorize(:cyan)

    begin
      LuckyMigrator::Runner.new.run_pending_migrations
      puts "✅  Done".colorize(:green)
    rescue e : PQ::PQError
      puts e.message.colorize(:red)
    end
  end
end
