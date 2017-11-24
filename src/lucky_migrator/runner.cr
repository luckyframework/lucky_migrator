require "db"
require "pg"
require "colorize"

class LuckyMigrator::Runner
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
  end

  def self.create_db
    run "createdb #{self.db_name}"
  end

  def self.run(command : String)
    Process.run command,
      shell: true,
      output: true,
      error: true
  end

  def run_pending_migrations
    setup_migration_tracking_tables
    if pending_migrations.empty?
      puts "Did nothing. No pending migrations.".colorize(:green)
    else
      pending_migrations.each &.new.up
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

  def redo_last_migration
    rollback_one
    run_pending_migrations
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

  private def create_table_for_tracking_migrations
    <<-SQL
    CREATE TABLE IF NOT EXISTS migrations (
      id serial PRIMARY KEY,
      version bigint NOT NULL
    )
    SQL
  end
end
