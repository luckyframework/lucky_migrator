module LuckyMigrator::StatementHelpers
  macro create(table_name)
    statement = LuckyMigrator::CreateTableStatement.new({{ table_name }}).build do
      {{ yield }}
    end

    execute statement
  end
end
