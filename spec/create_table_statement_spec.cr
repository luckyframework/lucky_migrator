require "./spec_helper"

describe LuckyMigrator::CreateTableStatement do
  it "can create tables" do
    statement = LuckyMigrator::CreateTableStatement.new(:users).build do
      add :name, String
      add :age, Int32
      add :joined_at, Time
      add :amount_paid, Float
      add :email, String, optional: true
    end

    statement.should eq <<-SQL
    CREATE TABLE users (
      id serial PRIMARY KEY,
      created_at timestamp NOT NULL,
      updated_at timestamp NOT NULL,
      name text NOT NULL,
      age int NOT NULL,
      joined_at timestamp NOT NULL,
      amount_paid decimal NOT NULL,
      email text)
    SQL
  end
end
