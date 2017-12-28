require "./spec_helper"

class MigrationThatPartiallyWorks::V999 < LuckyMigrator::Migration::V1
  def migrate
    create :fake_things do
      add foo : String
    end

    alter :table_does_not_exist do
      add foo : String?
    end
  end

  def rollback
  end
end

class MigrationWithOrderDependentExecute::V998 < LuckyMigrator::Migration::V1
  def migrate
    execute "CREATE TABLE execution_order ();"

    alter :execution_order do
      add bar : String?
    end

    execute "ALTER TABLE execution_order ADD new_col text;"
  end

  def rollback
  end
end

describe LuckyMigrator::Migration::V1 do
  it "executes statements in a transaction" do
    expect_raises Exception, %(relation "table_does_not_exist" does not exist) do
      MigrationThatPartiallyWorks::V999.new.up
    end

    exists = LuckyRecord::Repo.run do |db|
      db.query_one? "SELECT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'fake_things');", as: Bool
    end
    exists.should be_false
  end

  describe "statement execution order" do
    Spec.after_each do
      LuckyRecord::Repo.db.exec "DROP TABLE execution_order;"
    end

    it "runs execute statements in the order they were called" do
      MigrationWithOrderDependentExecute::V998.new.up
      columns = get_column_names("execution_order")
      columns.includes?("new_col").should be_true
      columns.includes?("bar").should be_true
    end
  end
end

def get_column_names(table_name)
  statement = <<-SQL
  SELECT column_name as name, is_nullable::boolean as nilable
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = '#{table_name}'
  SQL

  LuckyRecord::Repo.run { |db| db.query_all statement, as: String }
end