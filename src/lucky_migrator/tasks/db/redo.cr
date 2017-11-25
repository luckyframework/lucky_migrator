require "colorize"

class Db::Redo < LuckyCli::Task
  banner "Rollback then run the last migration"

  def call
    begin
      Db::Rollback.new.call
      Db::Migrate.new.call
    rescue e : PQ::PQError
      puts e.message.colorize(:red)
    end
  end
end
