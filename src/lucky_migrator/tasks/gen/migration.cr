require "colorize"
require "ecr"
require "file_utils"
require "../../../lucky_migrator"

class LuckyMigrator::MigrationGenerator
  include LuckyCli::TextHelpers

  getter :name
  @_version : String?

  ECR.def_to_s "#{__DIR__}/migration.ecr"

  def initialize(@name : String)
  end

  def generate
    ensure_camelcase_name
    make_migrations_folder_if_missing
    File.write(file_path, contents)
    puts "Created #{migration_class_name.colorize(:green)} in .#{relative_file_path.colorize(:green)}"
  end

  private def ensure_camelcase_name
    if name.camelcase != name
      raise <<-ERROR
      Migration must be in camel case.

        #{green_arrow} Try this instead: #{"lucky gen.migration #{name.camelcase}".colorize(:green)}
      ERROR
    end
  end

  private def migration_class_name
    "#{name}::V#{version}"
  end

  private def make_migrations_folder_if_missing
    FileUtils.mkdir_p Dir.current + "/db/migrations"
  end

  private def file_path
    Dir.current + relative_file_path
  end

  private def relative_file_path
    "/db/migrations/#{version}_#{name.underscore}.cr"
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
    LuckyMigrator.run do
      if ARGV.first? == nil
        raise "Migration name is required. Example: lucky gen.migration CreateUsers".colorize(:red).to_s
      else
        LuckyMigrator::MigrationGenerator.new(name: ARGV.first).generate
      end
    end
  end
end
