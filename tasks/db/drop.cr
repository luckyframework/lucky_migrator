require "db"
require "pg"
require "colorize"

raise "Requires a database name given as first option" if ARGV.first?.nil?

DB_COMMAND = "DROP DATABASE #{ARGV.first?}"
puts "Dropping database with: #{DB_COMMAND.colorize(:cyan)}"

begin
  DB.open("postgres://localhost") do |db|
    db.exec DB_COMMAND
  end
  puts "✅  Done".colorize(:green)
rescue e : PQ::PQError
  puts e.message.colorize(:red)
end
