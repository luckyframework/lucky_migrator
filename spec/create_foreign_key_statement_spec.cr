require "./spec_helper"

describe LuckyMigrator::CreateForeignKeyStatement do
  it "generates correct sql" do
    statement = LuckyMigrator::CreateForeignKeyStatement.new(:comments, :users).build
    statement.should eq "ALTER TABLE comments ADD CONSTRAINT comments_user_id_fk FOREIGN KEY (user_id) REFERENCES users (id);"

    statement = LuckyMigrator::CreateForeignKeyStatement.new(:comments, :users, column: :author_id, primary_key: :uid, on_delete: :cascade).build
    statement.should eq "ALTER TABLE comments ADD CONSTRAINT comments_author_id_fk FOREIGN KEY (author_id) REFERENCES users (uid) ON DELETE CASCADE;"
  end

  it "raises error on invalid on_delete strategy" do
    expect_raises Exception, "on_delete: :cascad is not supported. Please use :cascade, :restrict, or :nullify" do
      LuckyMigrator::CreateForeignKeyStatement.new(:comments, :users, on_delete: :cascad).build
    end
  end
end
