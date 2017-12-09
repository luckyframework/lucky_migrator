require "colorize"

class Db::Create < LuckyCli::Task
  banner "Create the database"

  def call
    begin
      LuckyMigrator::Runner.create_db
      puts "Done creating #{LuckyMigrator::Runner.db_name.colorize(:green)}"
    rescue e : PQ::PQError
      puts e.message.colorize(:red)
      exit(1)
    rescue e : Exception
      puts e.message.colorize(:red)
      exit(1)
    end
  end
end
