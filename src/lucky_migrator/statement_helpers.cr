module LuckyMigrator::StatementHelpers
  macro create(table_name)
    statements = LuckyMigrator::CreateTableStatement.new({{ table_name }}).build do
      {{ yield }}
    end.statements

    statements.each do |statement|
      execute statement
    end
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

  def create_foreign_key(from : Symbol, to : Symbol, column : Symbol, primary_key = :id, on_delete = :do_nothing)
    execute CreateForeignKeyStatement.new(from, to, column, primary_key, on_delete).build
  end

  def create_index(table_name : Symbol, column : Symbol, unique = false, using = :btree)
    execute CreateIndexStatement.new(table_name, column, using, unique).build
  end
end
