class CreateUsers::V001 < LuckyMigrator::Migration::V1
  def migrate
    create :users do
      add first_name : String, index: true
      add last_name : String
      add age : Int32, default: 1
      add num : Int64?, default: 1
      add salary : Float, precision: 10, scale: 2, default: 1.0
      add completed : Bool, default: false
      add joined_at : Time, default: :now
    end

    execute "CREATE INDEX users_num_index ON users USING btree (num);"

    create_index :users, [:first_name, :last_name], unique: true
  end

  def rollback
    drop :users
  end
end
