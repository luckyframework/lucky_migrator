require "./spec_helper"

describe LuckyMigrator::CreateIndexStatement do
  it "generates correct sql" do
    index_def = LuckyMigrator::CreateIndexStatement.new(:users, column: :email, using: :btree, unique: true)
    index_def.build.should eq "CREATE UNIQUE INDEX users_email_index ON users USING btree (email);"

    index_def = LuckyMigrator::CreateIndexStatement.new(:users, column: :email, using: :btree)
    index_def.build.should eq "CREATE INDEX users_email_index ON users USING btree (email);"
  end
end