require "db"
require "pg"
require "colorize"

class LuckyMigrator::Runner
  extend LuckyCli::TextHelpers

  @@migrations = [] of LuckyMigrator::Migration::V1.class

  Habitat.create do
    setting database : String
  end

  def self.db_name
    settings.database
  end

  def self.migrations
    @@migrations
  end

  def self.drop_db
    run "dropdb #{self.db_name}"
  rescue e : Exception
    if (message = e.message) && message.includes?(%("#{self.db_name}" does not exist))
      puts "Already dropped #{self.db_name.colorize(:green)}"
      exit(0)
    else
      raise e
    end
  end

  def self.create_db
    run "createdb #{self.db_name}"
  rescue e : Exception
    if (message = e.message) && message.includes?(%("#{self.db_name}" already exists))
      puts "Already created #{self.db_name.colorize(:green)}"
      exit(0)
    elsif (message = e.message) && (message.includes?("createdb: not found") || message.includes?("No command 'createdb' found"))
      raise <<-ERROR
      #{message}

        #{green_arrow} If you are on macOS  you can install postgres tools from #{macos_postgres_tools_link}
        #{green_arrow} If you are on linux you can try running #{linux_postgres_installation_instructions}
        #{green_arrow} If you are on CI or some servers, there may already be a database created so you don't need this command"
      ERROR
    else
      raise e
    end
  end

  private def self.macos_postgres_tools_link
    "https://postgresapp.com/documentation/cli-tools.html".colorize(:green)
  end

  private def self.linux_postgres_installation_instructions
    "sudo apt-get update && sudo apt-get install postgresql postgresql-contrib".colorize(:green)
  end

  def self.run(command : String)
    error_messages = IO::Memory.new
    result = Process.run command,
      shell: true,
      output: STDOUT,
      error: error_messages
    unless result.success?
      raise error_messages.to_s
      exit(1)
    end
  end

  def run_pending_migrations
    prepare_for_migration do
      pending_migrations.each &.new.up
    end
  end

  def run_next_migration
    prepare_for_migration do
      pending_migrations.first.new.up
    end
  end

  def rollback_all
    setup_migration_tracking_tables
    migrated_migrations.reverse.each &.new.down
  end

  def rollback_one
    setup_migration_tracking_tables
    if migrated_migrations.empty?
      puts "Did nothing. No migration to roll back.".colorize(:green)
    else
      migrated_migrations.last.new.down
    end
  end

  def ensure_migrated!
    if pending_migrations.any?
      raise "There are pending migrations. Please run lucky db.migrate"
    end
  end

  private def migrated_migrations
    @@migrations.select &.new.migrated?
  end

  private def pending_migrations
    @@migrations.select &.new.pending?
  end

  private def setup_migration_tracking_tables
    DB.open(LuckyRecord::Repo.settings.url) do |db|
      db.exec create_table_for_tracking_migrations
    end
  end

  private def prepare_for_migration
    setup_migration_tracking_tables
    if pending_migrations.empty?
      puts "Did nothing. No pending migrations.".colorize(:green)
    else
      yield
    end
  end

  private def create_table_for_tracking_migrations
    <<-SQL
    CREATE TABLE IF NOT EXISTS migrations (
      id serial PRIMARY KEY,
      version bigint NOT NULL
    )
    SQL
  end
end
