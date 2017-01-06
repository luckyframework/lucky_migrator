require "colorize"
require "ecr"

class LuckyMigrator::MigrationGenerator
  getter :name
  @_version : String?

  ECR.def_to_s "#{__DIR__}/migration.ecr"

  def initialize(@name : String)
  end

  def generate
    File.write(filename, contents)
  end

  private def filename
    Dir.current + "/db/migrations/#{version}_#{name.underscore}.cr"
  end

  private def version
    @_version ||= Time.now.to_s("%Y%m%d%H%M%S")
  end

  private def contents
    to_s
  end
end

class Gen::Migration < LuckyCli::Task
  banner "Generate a new migration"

  def call
    if ARGV.first? == nil
      puts "Migration name is required. Example: migrate.cr CreateUsers".colorize(:red)
    else
      LuckyMigrator::MigrationGenerator.new(name: ARGV.first).generate
      puts "Created migration"
    end
  end
end
