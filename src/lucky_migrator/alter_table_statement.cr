require "./column_default_helpers"
require "./column_type_option_helpers"
require "./index_statement_helpers.cr"

class LuckyMigrator::AlterTableStatement
  include LuckyMigrator::IndexStatementHelpers
  include LuckyMigrator::ColumnTypeOptionHelpers
  include LuckyMigrator::ColumnDefaultHelpers

  getter rows = [] of String
  getter dropped_rows = [] of String

  def initialize(@table_name : Symbol)
  end

  # Accepts a block to alter a table using the `add` method. The generated sql
  # statements are aggregated in the `statements` getter.
  #
  # ## Usage
  #
  # ```
  # built = LuckyMigrator::AlterTableStatement.new(:users).build do
  #   add name : String
  #   add age : Int32
  #   remove old_field
  # end
  #
  # built.statements
  # # => [
  # "ALTER TABLE users
  #   ADD name text NOT NULL,
  #   ADD age int NOT NULL,
  #   DROP old_field"
  # ]
  # ```
  def build
    with self yield
    self
  end

  def statements
    [alter_statement] + index_statements
  end

  def alter_statement
    String.build do |statement|
      statement << "ALTER TABLE #{@table_name}"
      statement << "\n"
      statement << (rows + dropped_rows).join(",\n")
    end
  end

  macro add(type_declaration, index = false, using = :btree, unique = false, default = nil, **type_options)
    {% options = type_options.empty? ? nil : type_options %}

    {% if type_declaration.type.is_a?(Union) %}
      add_column :{{ type_declaration.var }}, {{ type_declaration.type.types.first }}, true, default: {{ default }}, options: {{ options }}
    {% else %}
      if {{ default }}.nil?
        raise "must provide a default value when adding a required column"
      end
      add_column :{{ type_declaration.var }}, {{ type_declaration.type }}, false, default: {{ default }}, options: {{ options }}
    {% end %}

    {% if index || unique %}
      add_index :{{ type_declaration.var }}, using: {{ using }}, unique: {{ unique }}
    {% end %}
  end

  def add_column(name : Symbol, type : ColumnType, optional = false, default : ColumnDefaultType? = nil, options : NamedTuple? = nil)
    if options
      column_type_with_options = column_type(type, **options)
    else
      column_type_with_options = column_type(type)
    end

    rows << String.build do |row|
      row << "  ADD "
      row << name.to_s
      row << " "
      row << column_type_with_options
      row << null_fragment(optional)
      row << default_value(type, default) unless default.nil?
    end
  end

  def remove(name : Symbol)
    dropped_rows << "  DROP #{name.to_s}"
  end

  def null_fragment(optional)
    if optional
      ""
    else
      " NOT NULL"
    end
  end
end
