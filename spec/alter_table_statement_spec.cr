require "./spec_helper"

describe LuckyMigrator::AlterTableStatement do
  it "can alter tables" do
    built = LuckyMigrator::AlterTableStatement.new(:users).build do
      add name : String
      add age : Int32
      add completed : Bool
      add joined_at : Time
      add amount_paid : Float
      add email : String?
      remove :old_field
    end

    built.statements.first.should eq <<-SQL
    ALTER TABLE users
      ADD name text NOT NULL,
      ADD age int NOT NULL,
      ADD completed boolean NOT NULL,
      ADD joined_at timestamptz NOT NULL,
      ADD amount_paid decimal NOT NULL,
      ADD email text,
      DROP old_field
    SQL
  end

  it "sets default values" do
    built = LuckyMigrator::AlterTableStatement.new(:users).build do
      add name : String, default: "name"
      add email : String?, default: "optional"
      add age : Int32, default: 1
      add num : Int64, default: 1
      add amount_paid : Float, default: 1.0, precision: 10, scale: 5
      add completed : Bool, default: false
      add joined_at : Time, default: :now
      add future_time : Time, default: Time.new
    end

    built.statements.size.should eq 1
    built.statements.first.should eq <<-SQL
    ALTER TABLE users
      ADD name text NOT NULL DEFAULT 'name',
      ADD email text DEFAULT 'optional',
      ADD age int NOT NULL DEFAULT 1,
      ADD num bigint NOT NULL DEFAULT 1,
      ADD amount_paid decimal(10,5) NOT NULL DEFAULT 1.0,
      ADD completed boolean NOT NULL DEFAULT false,
      ADD joined_at timestamptz NOT NULL DEFAULT NOW(),
      ADD future_time timestamptz NOT NULL DEFAULT '#{Time.new.to_utc}'
    SQL
  end
end
