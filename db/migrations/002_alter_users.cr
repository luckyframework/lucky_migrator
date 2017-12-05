class AlterUsers::V002 < LuckyMigrator::Migration::V1
  def migrate
    alter :users do
      remove :first_name
      add name : String, default: "Jon"
      add nickname : String?
    end

    drop_index :users, :last_name, if_exists: true, on_delete: :cascade
    make_optional :users, :name
  end

  def rollback
    alter :users do
      remove :name
      remove :nickname
      add first_name : String
    end
  end
end
