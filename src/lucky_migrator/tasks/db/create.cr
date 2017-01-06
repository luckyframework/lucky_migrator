require "colorize"

class Db::Create < LuckyCli::Task
  banner "Create the database"

  def call
    raise "Requires a database name given as first option" if ARGV.first?.nil?

    db_command = "CREATE DATABASE #{ARGV.first}"
    puts "Creating database with: #{db_command.colorize(:cyan)}"

    begin
      DB.open("postgres://localhost") do |db|
        db.exec db_command
      end
      puts "✅  Done".colorize(:green)
    rescue e : PQ::PQError
      puts e.message.colorize(:red)
    end
  end
end
