require "colorize"

class Db::Drop < LuckyCli::Task
  banner "Drop the database"

  def call
    db_command = "DROP DATABASE #{ARGV.first?}"
    raise "Requires a database name given as first option" if ARGV.first?.nil?
    puts "Dropping database with: #{db_command.colorize(:cyan)}"

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
