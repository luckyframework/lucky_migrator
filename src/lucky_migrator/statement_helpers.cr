module LuckyMigrator::StatementHelpers
  macro create(table_name)
    statement = LuckyMigrator::CreateTableStatement.new({{ table_name }}).build do
      {{ yield }}
    end

    execute statement
  end

  def drop(table_name)
    execute LuckyMigrator::DropTableStatement.new(table_name).build
  end

  macro alter(table_name)
    statement = LuckyMigrator::AlterTableStatement.new({{ table_name }}).build do
      {{ yield }}
    end

    execute statement
  end
end
