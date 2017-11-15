require "./spec_helper"

describe IndexDefinition do
  it "generates correct sql" do
    index_def = IndexDefinition.new(:users, column: :email, using: :btree, unique: true)
    index_def.build.should eq "  CREATE UNIQUE INDEX users_email_index ON users USING btree (email);"
  end
end