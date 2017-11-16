require "./spec_helper"

describe LuckyMigrator::CreateTableStatement do
  it "can create tables" do
    built = LuckyMigrator::CreateTableStatement.new(:users).build do
      add name : String
      add age : Int32
      add completed : Bool
      add joined_at : Time
      add amount_paid : Float
      add email : String?
    end

    built.statements.size.should eq 1
    built.statements.first.should eq <<-SQL
    CREATE TABLE users (
      id serial PRIMARY KEY,
      created_at timestamp NOT NULL,
      updated_at timestamp NOT NULL,
      name text NOT NULL,
      age int NOT NULL,
      completed boolean NOT NULL,
      joined_at timestamp NOT NULL,
      amount_paid decimal NOT NULL,
      email text);
    SQL

    built.table_statement.should eq built.statements.first
  end

  describe "indices" do
    it "can create tables with indices" do
      built = LuckyMigrator::CreateTableStatement.new(:users).build do
        add name : String, index: true
        add age : Int32, unique: true
        add email : String

        add_index :email, unique: true
      end

      built.statements.size.should eq 4
      built.index_statements.size.should eq 3

      built.table_statement.should eq <<-SQL
      CREATE TABLE users (
        id serial PRIMARY KEY,
        created_at timestamp NOT NULL,
        updated_at timestamp NOT NULL,
        name text NOT NULL,
        age int NOT NULL,
        email text NOT NULL);
      SQL
      built.statements[1].should eq "  CREATE INDEX users_name_index ON users USING btree (name);"
      built.statements[2].should eq "  CREATE UNIQUE INDEX users_age_index ON users USING btree (age);"
      built.statements[3].should eq "  CREATE UNIQUE INDEX users_email_index ON users USING btree (email);"
    end

    it "raises error on columns with non allowed index types" do
      expect_raises Exception, "index type 'gist' not supported" do
        LuckyMigrator::CreateTableStatement.new(:users).build do
          add email : String, index: true, using: :gist
        end
      end
    end

    it "raises error when index already exists" do
      expect_raises Exception, "index on users.email already exists" do
        LuckyMigrator::CreateTableStatement.new(:users).build do
          add email : String, index: true

          add_index :email, unique: true
        end
      end
    end
  end
end
