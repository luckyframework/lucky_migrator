class CreateUsers::V001 < LuckyMigrator::Migration::V1
  def migrate
    create :users do
      add :first_name, String
    end
  end

  def rollback
    execute "DROP TABLE users"
  end
end
