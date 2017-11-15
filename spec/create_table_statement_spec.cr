require "./spec_helper"

describe LuckyMigrator::CreateTableStatement do
  it "can create tables" do
    statement = LuckyMigrator::CreateTableStatement.new(:users).build do
      add name : String
      add age : Int32
      add completed : Bool
      add joined_at : Time
      add amount_paid : Float
      add email : String?
    end

    statement.should eq <<-SQL
    CREATE TABLE users (
      id serial PRIMARY KEY,
      created_at timestamp NOT NULL,
      updated_at timestamp NOT NULL,
      name text NOT NULL,
      age int NOT NULL,
      completed boolean NOT NULL,
      joined_at timestamp NOT NULL,
      amount_paid decimal NOT NULL,
      email text)
    SQL
  end

  describe "indices" do
    it "can create tables with indices" do
      statement = LuckyMigrator::CreateTableStatement.new(:users).build do
        add name : String, index: true
        add age : Int32, unique: true
        add email : String

        add_index :email, unique: true
      end

      statement.should eq <<-SQL
      CREATE TABLE users (
        id serial PRIMARY KEY,
        created_at timestamp NOT NULL,
        updated_at timestamp NOT NULL,
        name text NOT NULL,
        age int NOT NULL,
        email text NOT NULL)
        CREATE INDEX users_name_index ON users USING btree (name);
        CREATE UNIQUE INDEX users_age_index ON users USING btree (age);
        CREATE UNIQUE INDEX users_email_index ON users USING btree (email);
      SQL
    end

    it "raises error on columns with non allowed index types" do
      expect_raises Exception, "index type 'gist' not supported" do
        LuckyMigrator::CreateTableStatement.new(:users).build do
          add email : String, index: true, using: :gist
        end
      end
    end

    it "raises error when indexe already exists" do
      expect_raises Exception, "index on users.email already exists" do
        LuckyMigrator::CreateTableStatement.new(:users).build do
          add email : String, index: true

          add_index :email, unique: true
        end
      end
    end
  end
end
