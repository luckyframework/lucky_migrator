require "./spec_helper"

describe LuckyMigrator::AlterTableStatement do
  it "can alter tables with defaults, indices and options" do
    built = LuckyMigrator::AlterTableStatement.new(:users).build do
      add name : String?
      add email : String, default: "user@lucky.com", fill_existing_with: "noreply@lucky.com"
      add age : Int32, default: 1, unique: true
      add num : Int64, default: 1, index: true
      add amount_paid : Float, default: 1.0, precision: 10, scale: 5
      add completed : Bool, default: false
      add joined_at : Time, default: :now
      add updated_at : Time, fill_existing_with: :now
      add future_time : Time, default: Time.new
      remove :old_field
    end

    built.statements.size.should eq 7
    built.statements.first.should eq <<-SQL
    ALTER TABLE users
      ADD name text,
      ADD email text DEFAULT 'user@lucky.com',
      ADD age int NOT NULL DEFAULT 1,
      ADD num bigint NOT NULL DEFAULT 1,
      ADD amount_paid decimal(10,5) NOT NULL DEFAULT 1.0,
      ADD completed boolean NOT NULL DEFAULT false,
      ADD joined_at timestamptz NOT NULL DEFAULT NOW(),
      ADD updated_at timestamptz,
      ADD future_time timestamptz NOT NULL DEFAULT '#{Time.new.to_utc}',
      DROP old_field
    SQL

    built.statements[1].should eq "CREATE UNIQUE INDEX users_age_index ON users USING btree (age);"
    built.statements[2].should eq "CREATE INDEX users_num_index ON users USING btree (num);"
    built.statements[3].should eq "UPDATE users SET email = 'noreply@lucky.com';"
    built.statements[4].should eq "ALTER TABLE users ALTER COLUMN email SET NOT NULL;"
    built.statements[5].should eq "UPDATE users SET updated_at = NOW();"
    built.statements[6].should eq "ALTER TABLE users ALTER COLUMN updated_at SET NOT NULL;"
  end

  it "raises when adding a required column without a default or fill_existing_with argument" do
    expect_raises Exception, "must provide a default value or use fill_existing_with when adding a required field to an existing table" do
      LuckyMigrator::AlterTableStatement.new(:users).build do
        add email : String
      end
    end
  end
end
