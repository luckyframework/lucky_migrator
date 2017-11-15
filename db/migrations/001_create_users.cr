class CreateUsers::V001 < LuckyMigrator::Migration::V1
  def migrate
    create :users do
      add first_name : String, index: true
    end
  end

  def rollback
    drop :users
  end
end
