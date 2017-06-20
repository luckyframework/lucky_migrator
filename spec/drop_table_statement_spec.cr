require "./spec_helper"

describe LuckyMigrator::DropTableStatement do
  it "can drop table" do
    statement = LuckyMigrator::DropTableStatement.new(:users).build

    statement.should eq "DROP TABLE users"
  end
end
