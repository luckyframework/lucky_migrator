require "colorize"
require "ecr"

class Migrate::MigrationGenerator
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

if ARGV.first? == nil
  puts "Migration name is required. Example: migrate.cr CreateUsers".colorize(:red)
else
  Migrate::MigrationGenerator.new(name: ARGV.first).generate
end
