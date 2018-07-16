class Db::Create < LuckyCli::Task
  banner "Create the database"

  def initialize(@quiet : Bool = false)
    parse_options
  end

  def call
    LuckyMigrator.run do
      LuckyMigrator::Runner.create_db(@quiet)
    end
  end

  private def parse_options
    OptionParser.parse! do |parser|
      parser.banner = "Usage: lucky db.create [arguments]"
      parser.on("--quiet", "Doesn't print success output") { @quiet = true }
      parser.on("-h", "--help", "Help here") {
        puts parser
        exit(0)
      }
    end
  end
end
