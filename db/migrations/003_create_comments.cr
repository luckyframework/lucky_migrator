class CreateComments::V20171117153222 < LuckyMigrator::Migration::V1
  def migrate
    create :comments do
     add author_id : Int64
    end

    add_foreign_key :comments, to: :users, column: :author_id, primary_key: :id, on_delete: :cascade
  end

  def rollback
    drop :comments
  end
end
