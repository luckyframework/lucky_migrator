require "colorize"

class Db::Rollback < LuckyCli::Task
  banner "Rollback the last migration"

  def call
    puts "Rolling back...".colorize(:cyan)

    begin
      LuckyMigrator::Runner.new.rollback_one
      puts "✅  Done".colorize(:green)
    rescue e : PQ::PQError
      puts e.message.colorize(:red)
    end
  end
end
