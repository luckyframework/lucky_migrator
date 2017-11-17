require "./spec_helper"

describe LuckyMigrator::CreateIndexStatement do
  it "generates correct sql" do
    statement = LuckyMigrator::CreateIndexStatement.new(:users, :email).build
    statement.should eq "CREATE INDEX users_email_index ON users USING btree (email);"

    statement = LuckyMigrator::CreateIndexStatement.new(:users, column: :email, using: :btree, unique: true).build
    statement.should eq "CREATE UNIQUE INDEX users_email_index ON users USING btree (email);"
  end
end
