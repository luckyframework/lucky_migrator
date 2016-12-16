require "./init"

puts "Rolling back all migrations...".colorize(:cyan)

Migrate::Runner.db_name = ARGV.first? || raise "Requires db name passed as first arg"

begin
  Migrate::Runner.new.rollback_all
  puts "✅  Done".colorize(:green)
rescue e : PQ::PQError
  puts e.message.colorize(:red)
end
