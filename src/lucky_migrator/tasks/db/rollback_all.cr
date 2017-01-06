require "colorize"

class Db::RollbackAll < LuckyCli::Task
  banner "Rollback all migrations"

  def call
    puts "Rolling back all migrations...".colorize(:cyan)

    LuckyMigrator::Runner.db_name = ARGV.first? || raise "Requires db name passed as first arg"

    begin
      LuckyMigrator::Runner.new.rollback_all
      puts "✅  Done".colorize(:green)
    rescue e : PQ::PQError
      puts e.message.colorize(:red)
    end
  end
end
