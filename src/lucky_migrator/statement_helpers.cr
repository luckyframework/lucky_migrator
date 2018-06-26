module LuckyMigrator::StatementHelpers
  macro create(table_name, primary_key_type = LuckyMigrator::PrimaryKeyType::BigSerial)
    statements = LuckyMigrator::CreateTableStatement.new({{ table_name }}, {{ primary_key_type }}).build do
      {{ yield }}
    end.statements

    statements.each do |statement|
      prepared_statements << statement
    end
  end

  def drop(table_name)
    prepared_statements << LuckyMigrator::DropTableStatement.new(table_name).build
  end

  macro alter(table_name)
    statements = LuckyMigrator::AlterTableStatement.new({{ table_name }}).build do
      {{ yield }}
    end.statements

    statements.each do |statement|
      prepared_statements <<  statement
    end
  end

  def create_foreign_key(from : Symbol, to : Symbol, on_delete : Symbol, column : Symbol?, primary_key = :id)
    prepared_statements << CreateForeignKeyStatement.new(from, to, on_delete, column, primary_key).build
  end

  def create_index(table_name : Symbol, column : Symbol, unique = false, using = :btree)
    prepared_statements << CreateIndexStatement.new(table_name, column, using, unique).build
  end

  def drop_index(table_name : Symbol, column : Symbol, if_exists = false, on_delete = :do_nothing)
    prepared_statements << LuckyMigrator::DropIndexStatement.new(table_name, column, if_exists, on_delete).build
  end

  def make_required(table : Symbol, column : Symbol)
    prepared_statements << LuckyMigrator::ChangeNullStatement.new(table, column, required: true).build
  end

  def make_optional(table : Symbol, column : Symbol)
    prepared_statements << LuckyMigrator::ChangeNullStatement.new(table, column, required: false).build
  end
end
