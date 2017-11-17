class CreateComments::V20171117153222 < LuckyMigrator::Migration::V1
  def migrate
    create :comments do
      belongs_to User, references: :users
      add author_id : Int64
    end

    create_foreign_key :comments, to: :users, column: :author_id, primary_key: :id, on_delete: :cascade
  end

  def rollback
    drop :comments
  end
end
