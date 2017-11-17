class CreateUsers::V001 < LuckyMigrator::Migration::V1
  def migrate
    create :users do
      add first_name : String, index: true
      add last_name : String
    end

    add_index :users, :last_name, unique: true
    # add_index :users, :first_name, unique: true # Note: breaks the migration
  end

  def rollback
    drop :users
  end
end
