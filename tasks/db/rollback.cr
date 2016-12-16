require "./init"

puts "Rolling back...".colorize(:cyan)

Migrate::Runner.db_name = ARGV.first? || raise "Requires db name passed as first arg"

begin
  Migrate::Runner.new.rollback_one
  puts "✅  Done".colorize(:green)
rescue e : PQ::PQError
  puts e.message.colorize(:red)
end
