class CreateUsers::V001 < Migrate::Migration::V1
  def migrate
    execute <<-SQL
    CREATE TABLE users (
      id serial PRIMARY KEY,
      first_name text NOT NULL
    )
    SQL
  end

  def rollback
    execute "DROP TABLE users"
  end
end
