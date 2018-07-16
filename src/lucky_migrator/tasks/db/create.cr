class Db::Create < LuckyCli::Task
  banner "Create the database"

  def initialize(@quiet : Bool = false)
    @quiet = ARGV.includes? "--quiet"
  end

  def call
    LuckyMigrator.run do
      LuckyMigrator::Runner.create_db(@quiet)
    end
  end
end
