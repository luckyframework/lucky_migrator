require "colorize"
require "./*"

abstract class Migrate::Migration::V1
  macro inherited
    Migrate::Runner.migrations << self

    def version
      get_version_from_filename
    end

    macro get_version_from_filename
      {{@type.name.split("::").last.gsub(/V/, "")}}
    end
  end

  abstract def migrate
  abstract def version

  def up
    if migrated?
      puts "Already migrated #{self.class.name.colorize(:cyan)}"
    else
      migrate
      track_migration
      puts "Migrated #{self.class.name.colorize(:green)}"
    end
  end

  def down
    if pending?
      puts "Already rolled back #{self.class.name.colorize(:cyan)}"
    else
      rollback
      untrack_migration
      puts "Rolled back #{self.class.name.colorize(:green)}"
    end
  end

  def pending?
    !migrated?
  end

  def migrated?
    DB.open("postgres://localhost/migrate_cr_dev") do |db|
      db.query_one? "SELECT id FROM migrations WHERE version = $1", version, as: Int32
    end
  end

  private def track_migration
    execute "INSERT INTO migrations(version) VALUES ($1)", version
  end

  private def untrack_migration
    execute "DELETE FROM migrations WHERE version = $1", version
  end

  private def execute(*args)
    DB.open("postgres://localhost/migrate_cr_dev") do |db|
      db.exec *args
    end
  end
end
