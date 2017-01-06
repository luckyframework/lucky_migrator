require "db"
require "pg"
require "colorize"

class LuckyMigrator::Runner
  @@migrations = [] of LuckyMigrator::Migration::V1.class
  @@db_name : String?

  def self.db_name=(name)
    @@db_name = name
  end

  def self.db_name
    if db_name = @@db_name
      db_name
    else
      raise <<-ERROR
      Must set the db name for Migration::Runner

      Example:

          LuckyMigrator::Runner.db_name = "my_db_name"


      ERROR
    end
  end

  def self.migrations
    @@migrations
  end

  def run_pending_migrations
    setup_migration_tracking_tables
    pending_migrations.each &.new.up
  end

  def rollback_all
    setup_migration_tracking_tables
    migrated_migrations.each &.new.down
  end

  def rollback_one
    setup_migration_tracking_tables
    if migrated_migrations.empty?
      puts "All migrations have been rolled back"
    else
      migrated_migrations.last.new.down
    end
  end

  private def migrated_migrations
    @@migrations.select &.new.migrated?
  end

  private def pending_migrations
    @@migrations.select &.new.pending?
  end

  private def setup_migration_tracking_tables
    DB.open("postgres://localhost/#{self.class.db_name}") do |db|
      db.exec create_table_for_tracking_migrations
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
