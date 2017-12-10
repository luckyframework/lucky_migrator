class CreateComments::V20171117153222 < LuckyMigrator::Migration::V1
  def migrate
    create :comments do
      belongs_to User, references: :users, on_delete: :cascade
      add author_id : Int64
    end

    create_foreign_key :comments, :users, on_delete: :cascade, column: :author_id, primary_key: :id
  end

  def rollback
    drop :comments
  end
end
