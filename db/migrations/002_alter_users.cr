class AlterUsers::V002 < LuckyMigrator::Migration::V1
  def migrate
    alter :users do
      remove :first_name
      add name : String, default: "Jon", unique: true
      add nickname : String?, index: true
    end

    drop_index :users, :last_name, if_exists: true, on_delete: :cascade
  end

  def rollback
    alter :users do
      remove :name
      remove :nickname
      add first_name : String
    end
  end
end
