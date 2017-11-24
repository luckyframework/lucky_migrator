class CreateUsers::V001 < LuckyMigrator::Migration::V1
  def migrate
    create :users do
      add first_name : String, index: true
      add last_name : String
      add salary : Float, precision: 10, scale: 2
    end

    create_index :users, :last_name, unique: true
  end

  def rollback
    drop :users
  end
end
