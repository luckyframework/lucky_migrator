require "./spec_helper"

describe LuckyMigrator::DropIndexStatement do
  it "generates correct sql" do
    statement = LuckyMigrator::DropIndexStatement.new(:users, :email, on_delete: :cascade, if_exists: true).build
    statement.should eq "DROP INDEX IF EXISTS users_email_index CASCADE;"
  end
end
