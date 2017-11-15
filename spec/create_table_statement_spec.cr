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
    it "can create tables with inline indices" do
      statement = LuckyMigrator::CreateTableStatement.new(:users).build do
        add name : String, index: true, using: :btree
        add email : String, index: true, using: "btree", unique: true
      end

      statement.should eq <<-SQL
      CREATE TABLE users (
        id serial PRIMARY KEY,
        created_at timestamp NOT NULL,
        updated_at timestamp NOT NULL,
        name text NOT NULL,
        email text NOT NULL)
      CREATE INDEX users_name_index ON users USING btree (name);
      CREATE UNIQUE INDEX users_email_index ON users USING btree (email);
      SQL
    end

    it "can create indices manually with add_index" do
      statement = LuckyMigrator::CreateTableStatement.new(:users).build do
        add name : String
        add email : String

        add_index :name, using: :btree
        add_index :email, using: "btree", unique: true
      end

      statement.should eq <<-SQL
      CREATE TABLE users (
        id serial PRIMARY KEY,
        created_at timestamp NOT NULL,
        updated_at timestamp NOT NULL,
        name text NOT NULL,
        email text NOT NULL)
      CREATE INDEX users_name_index ON users USING btree (name);
      CREATE UNIQUE INDEX users_email_index ON users USING btree (email);
      SQL
    end

    it "defaults to btree" do
      statement = LuckyMigrator::CreateTableStatement.new(:users).build do
        add name : String, index: true
        add email : String

        add_index :email
      end

      statement.should eq <<-SQL
      CREATE TABLE users (
        id serial PRIMARY KEY,
        created_at timestamp NOT NULL,
        updated_at timestamp NOT NULL,
        name text NOT NULL,
        email text NOT NULL)
      CREATE INDEX users_name_index ON users USING btree (name);
      CREATE INDEX users_email_index ON users USING btree (email);
      SQL
    end

    it "raises error on columns with non allowed index types" do
      expect_raises Exception, "index type 'gist' not supported" do
        LuckyMigrator::CreateTableStatement.new(:users).build do
          add email : String, index: true, using: "gist"
        end
      end

      expect_raises Exception, "index type 'gist' not supported" do
        LuckyMigrator::CreateTableStatement.new(:users).build do
          add email : String

          add_index :email, using: :gist
        end
      end
    end

    it "raises error on columns with non btree index" do
      expect_raises Exception, "index type 'gist' not supported" do
        LuckyMigrator::CreateTableStatement.new(:users).build do
          add email : String

          add_index :email, using: :gist
        end
      end
    end
  end
end
