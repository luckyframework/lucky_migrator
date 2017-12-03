require "colorize"

class Db::Rollback < LuckyCli::Task
  banner "Rollback the last migration"

  def call
    begin
      LuckyMigrator::Runner.new.rollback_one
    rescue e : PQ::PQError
      puts e.message.colorize(:red)
      exit(1)
    end
  end
end
