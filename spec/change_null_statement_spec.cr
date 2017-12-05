require "./spec_helper"

describe LuckyMigrator::ChangeNullStatement do
  it "generates correct sql" do
    statement = LuckyMigrator::ChangeNullStatement.new(:users, :email, required: true).build
    statement.should eq "ALTER TABLE users ALTER COLUMN email SET NOT NULL;"

    statement = LuckyMigrator::ChangeNullStatement.new(:users, :email, required: false).build
    statement.should eq "ALTER TABLE users ALTER COLUMN email DROP NOT NULL;"
  end
end
