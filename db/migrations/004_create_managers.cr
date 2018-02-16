class CreateManagers::V20171117153223 < LuckyMigrator::Migration::V1
  def migrate
    create :managers do
      add name : String
    end

    alter :users do
      add_belongs_to employee : User, on_delete: :cascade
    end
  end

  def rollback
    drop :managers

    alter :users do
      remove_belongs_to :employee
    end
  end
end
