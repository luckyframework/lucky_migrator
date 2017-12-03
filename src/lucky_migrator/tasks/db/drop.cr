require "colorize"

class Db::Drop < LuckyCli::Task
  banner "Drop the database"

  def call
    begin
      LuckyMigrator::Runner.drop_db
      puts "Done dropping #{LuckyMigrator::Runner.db_name.colorize(:green)}"
    rescue e : PQ::PQError
      puts e.message.colorize(:red)
      exit(1)
    end
  end
end
