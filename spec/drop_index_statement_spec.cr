require "./spec_helper"

describe LuckyMigrator::DropIndexStatement do
  it "generates correct sql" do
    statement = LuckyMigrator::DropIndexStatement.new(:users, :email).build
    statement.should eq "DROP INDEX users_email_index;"
  end
end
