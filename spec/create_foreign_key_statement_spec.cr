require "./spec_helper"

describe LuckyMigrator::CreateForeignKeyStatement do
  it "generates correct sql" do
    statement = LuckyMigrator::CreateForeignKeyStatement.new(:comments, :users).build
    statement.should eq "ALTER TABLE comments ADD CONSTRAINT comments_user_id_fk FOREIGN KEY (user_id) REFERENCES users (id);"

    statement = LuckyMigrator::CreateForeignKeyStatement.new(:comments, :users, :custom_pk).build
    statement.should eq "ALTER TABLE comments ADD CONSTRAINT comments_user_id_fk FOREIGN KEY (user_id) REFERENCES users (custom_pk);"
  end
end