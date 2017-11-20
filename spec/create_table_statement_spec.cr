require "./spec_helper"

describe LuckyMigrator::CreateTableStatement do
  it "can create tables" do
    built = LuckyMigrator::CreateTableStatement.new(:users).build do
      add name : String
      add age : Int32
      add completed : Bool
      add joined_at : Time
      add amount_paid : Float, precision: 10, scale: 2
      add email : String?
    end

    built.statements.size.should eq 1
    built.statements.first.should eq <<-SQL
    CREATE TABLE users (
      id serial PRIMARY KEY,
      created_at timestamptz NOT NULL,
      updated_at timestamptz NOT NULL,
      name text NOT NULL,
      age int NOT NULL,
      completed boolean NOT NULL,
      joined_at timestamptz NOT NULL,
      amount_paid decimal(12,12) NOT NULL,
      email text);
    SQL
  end

  it "sets default values" do
    future_time = Time.new(2030,1,1)

    built = LuckyMigrator::CreateTableStatement.new(:users).build do
      add name : String, default: "name"
      add email : String?, default: "optional"
      add age : Int32, default: 1
      add num : Int64, default: 1
      add amount_paid : Float, default: 1.0
      add completed : Bool, default: false
      add joined_at : Time, default: :now
      add future_time : Time, default: future_time
    end

    built.statements.size.should eq 1
    built.statements.first.should eq <<-SQL
    CREATE TABLE users (
      id serial PRIMARY KEY,
      created_at timestamptz NOT NULL,
      updated_at timestamptz NOT NULL,
      name text NOT NULL DEFAULT 'name',
      email text DEFAULT 'optional',
      age int NOT NULL DEFAULT 1,
      num bigint NOT NULL DEFAULT 1,
      amount_paid decimal NOT NULL DEFAULT 1.0,
      completed boolean NOT NULL DEFAULT false,
      joined_at timestamptz NOT NULL DEFAULT NOW(),
      future_time timestamptz NOT NULL DEFAULT '#{future_time.to_utc}');
    SQL
  end

  it "raises on Int32 column with Int64 default" do
    future_time = Time.new(2030,1,1)

    expect_raises Exception, "Cannot set Int64 default for Int32 column 'age'. Either set the type to Int64 or change the default value." do
      built = LuckyMigrator::CreateTableStatement.new(:users).build do
        add age : Int32, default: 3_000_000_000
      end
    end
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
      built.statements.first.should eq <<-SQL
      CREATE TABLE users (
        id serial PRIMARY KEY,
        created_at timestamptz NOT NULL,
        updated_at timestamptz NOT NULL,
        name text NOT NULL,
        age int NOT NULL,
        email text NOT NULL);
      SQL
      built.statements[1].should eq "CREATE INDEX users_name_index ON users USING btree (name);"
      built.statements[2].should eq "CREATE UNIQUE INDEX users_age_index ON users USING btree (age);"
      built.statements[3].should eq "CREATE UNIQUE INDEX users_email_index ON users USING btree (email);"
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

  describe "associations" do
    it "can create associations" do
      built = LuckyMigrator::CreateTableStatement.new(:comments).build do
        belongs_to User, on_delete: :cascade
        belongs_to Post?
        belongs_to CategoryLabel, references: :custom_table
      end

      built.statements.first.should eq <<-SQL
      CREATE TABLE comments (
        id serial PRIMARY KEY,
        created_at timestamptz NOT NULL,
        updated_at timestamptz NOT NULL,
        user_id bigint NOT NULL REFERENCES users ON DELETE CASCADE,
        post_id bigint REFERENCES posts,
        category_label_id bigint NOT NULL REFERENCES custom_table);
      SQL

      built.statements[1].should eq "CREATE INDEX comments_user_id_index ON comments USING btree (user_id);"
      built.statements[2].should eq "CREATE INDEX comments_post_id_index ON comments USING btree (post_id);"
      built.statements[3].should eq "CREATE INDEX comments_category_label_id_index ON comments USING btree (category_label_id);"
    end

    it "raises error when on_delete strategy is invalid" do
      expect_raises Exception, "on_delete: :cascad is not supported. Please use :do_nothing, :cascade, :restrict, or :nullify" do
        LuckyMigrator::CreateTableStatement.new(:users).build do
          belongs_to User, on_delete: :cascad
        end
      end
    end
  end
end
