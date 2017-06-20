require "./spec_helper"

describe LuckyMigrator::AlterTableStatement do
  it "can alter tables" do
    statement = LuckyMigrator::AlterTableStatement.new(:users).build do
      add :name, String
      add :age, Int32
      add :joined_at, Time
      add :amount_paid, Float
      add :email, String, optional: true
      remove :old_field
    end

    statement.should eq <<-SQL
    ALTER TABLE users
      ADD name text NOT NULL,
      ADD age int NOT NULL,
      ADD joined_at timestamp NOT NULL,
      ADD amount_paid decimal NOT NULL,
      ADD email text,
      DROP old_field
    SQL
  end
end
