require "./index_statement_helpers.cr"

class LuckyMigrator::CreateTableStatement
  include LuckyMigrator::IndexStatementHelpers
  include LuckyMigrator::ColumnDefaultHelpers
  include LuckyMigrator::ColumnTypeOptionHelpers

  private getter rows = [] of String

  def initialize(@table_name : Symbol)
  end

  # Accepts a block to build a table and indices using `add` and `add_index` methods.
  #
  # The generated sql statements are aggregated in the `statements` method.
  #
  # ## Usage
  #
  # ```
  # built = LuckyMigrator::CreateTableStatement.new(:users).build do
  #   belongs_to Account, on_delete: :cascade
  #   add :email : String, unique: true
  # end
  #
  # built.statements
  # # => [
  #   "CREATE TABLE users (
  #     id serial PRIMARY KEY,
  #     created_at timestamptz NOT NULL,
  #     updated_at timestamptz NOT NULL,
  #     account_id bigint NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
  #     email text NOT NULL);",
  #   "CREATE UNIQUE INDEX users_email_index ON users USING btree (email);"
  # ]
  # ```
  def build : CreateTableStatement
    with self yield
    self
  end

  def statements
    [table_statement] + index_statements
  end

  private def table_statement
    String.build do |statement|
      statement << initial_table_statement
      statement << "\n"

      statement << rows.join(",\n")
      statement << ");"
    end
  end

  private def initial_table_statement
    <<-SQL
    CREATE TABLE #{@table_name} (
      id serial PRIMARY KEY,
      created_at timestamptz NOT NULL,
      updated_at timestamptz NOT NULL,
    SQL
  end

  # Generates raw sql from a type declaration and options passed in as named
  # variables.
  macro add(type_declaration, index = false, using = :btree, unique = false, default = nil, **type_options)
    {% options = type_options.empty? ? nil : type_options %}

    {% if type_declaration.type.is_a?(Union) %}
      add_column :{{ type_declaration.var }}, {{ type_declaration.type.types.first }}, optional: true, default: {{ default }}, options: {{ options }}
    {% else %}
      add_column :{{ type_declaration.var }}, {{ type_declaration.type }}, default: {{ default }}, options: {{ options }}
    {% end %}

    {% if index || unique %}
      add_index :{{ type_declaration.var }}, using: {{ using }}, unique: {{ unique }}
    {% end %}
  end

  def add_column(name, type : ColumnType, optional = false, reference = nil, on_delete = :do_nothing, default : ColumnDefaultType? = nil, options : NamedTuple? = nil)
    if options
      column_type_with_options = column_type(type, **options)
    else
      column_type_with_options = column_type(type)
    end

    rows << String.build do |row|
      row << "  "
      row << name.to_s
      row << " "
      row << column_type_with_options
      row << null_fragment(optional)
      row << default_value(type, default) unless default.nil?
      row << references(reference, on_delete)
    end
  end

  # Adds a references column and index given a model class and references option.
  macro belongs_to(model_class, on_delete, references = nil)
    {% optional = model_class.is_a?(Generic) %}

    {% if optional %}
      {% underscored_class = model_class.type_vars.first.stringify.underscore %}
    {% else %}
      {% underscored_class = model_class.names.first.stringify.underscore %}
    {% end %}

    {% foreign_key_name = underscored_class + "_id" %}
    %table_name = {{ references }} || LuckyInflector::Inflector.pluralize({{ underscored_class }})

    add_column :{{ foreign_key_name }}, Int64, {{ optional }}, reference: %table_name, on_delete: {{ on_delete }}
    add_index :{{ foreign_key_name }}
  end

  macro belongs_to(_type_declaration, references = nil)
    {% raise "Must use 'on_delete' when creating a belongs_to association.
      Example: belongs_to User, on_delete: :cascade" %}
  end

  def null_fragment(optional)
    if optional
      ""
    else
      " NOT NULL"
    end
  end

  def references(table_name : String | Symbol | Nil, on_delete = :do_nothing)
    if table_name.nil?
      ""
    elsif on_delete == :do_nothing
      " REFERENCES #{table_name}"
    elsif CreateForeignKeyStatement::ALLOWED_ON_DELETE_STRATEGIES.includes?(on_delete)
      " REFERENCES #{table_name}" + " ON DELETE " + "#{on_delete}".upcase
    else
      raise "on_delete: :#{on_delete} is not supported. Please use :do_nothing, :cascade, :restrict, or :nullify"
    end
  end
end
