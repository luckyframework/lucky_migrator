class LuckyMigrator::CreateTableStatement
  private getter rows = [] of String
  private getter index_statements = [] of String

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
  #     created_at timestamp NOT NULL,
  #     updated_at timestamp NOT NULL,
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
    {% options = type_options.empty? ? nil : type_options %})

    {% if type_declaration.type.is_a?(Union) %}
      add_column :{{ type_declaration.var }}, {{ type_declaration.type.types.first }}, optional: true, default: {{ default }}, options: {{ options }}
    {% else %}
      add_column :{{ type_declaration.var }}, {{ type_declaration.type }}, default: {{ default }}, options: {{ options }}
    {% end %}

    {% if index || unique %}
      add_index :{{ type_declaration.var }}, using: {{ using }}, unique: {{ unique }}
    {% end %}
  end

  def add_column(name, type : (String | Time | Int32 | Int64 | Float | Bool).class, optional = false, reference = nil, on_delete = :do_nothing,default : String | Time | Int32 | Int64 | Float | Bool | Symbol | Nil = nil, options : NamedTuple? = nil)

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
      row << default_value(type, default, name) unless default.nil?
      row << references(reference, on_delete)
    end
  end

  # Generates raw sql for adding an index to a table column. Accepts 'unique' and 'using' options.
  def add_index(column : Symbol, unique = false, using : Symbol = :btree)
    index = CreateIndexStatement.new(@table_name, column, using, unique).build
    index_statements << index unless index_added?(index, column)
  end

  # Returns false unless matching index exists. Ignores UNIQUE
  def index_added?(index : String, column : Symbol)
    return false unless index_statements.includes?(index) || index_statements.includes?(index.gsub(" UNIQUE", ""))
    raise "index on #{@table_name}.#{column} already exists"
  end

  # Adds a references column and index given a model class and references option.
  macro belongs_to(model_class, references = nil, on_delete = :do_nothing)
    {% optional = model_class.is_a?(Generic) %}

    {% if optional %}
      {% underscored_class = model_class.type_vars.first.stringify.underscore %}
    {% else %}
      {% underscored_class = model_class.names.first.stringify.underscore %}
    {% end %}

    {% foreign_key_name = underscored_class + "_id" %}
    %table_name = {{ references }} || pluralize({{ underscored_class }})

    add_column :{{ foreign_key_name }}, Int64, {{ optional }}, reference: %table_name, on_delete: {{ on_delete }}
    add_index :{{ foreign_key_name }}
  end

  def pluralize(word : String)
    if word.ends_with?("y")
      "#{word.rchop}ies"
    else
      "#{word}s"
    end
  end

  def default_value(type : String.class, default : String, name)
    if %w[now() current_time current_timestamp].includes?(default.downcase)
      return " DEFAULT NOW()"
    end
    return " DEFAULT '#{default}'"
  end

  def default_value(type : Time.class, default : (String | Time | Symbol), name)
    if default.is_a?(Symbol) && default == :now
      " DEFAULT NOW()"
    elsif default.is_a?(String) && %w[now() current_timestamp].includes?(default.downcase)
      " DEFAULT NOW()"
    elsif default.is_a?(Time)
      " DEFAULT '#{default.to_utc}'"
    else
      raise "Unrecognized default value for #{name}: #{default}. Please use :now, 'now()' or 'current_timestamp'"
    end
  end

  def default_value(type : (Int32 | Int64).class, default : (Int32 | Int64), name)
    if type == Int32 && default > Int32::MAX
      raise "Cannot set Int64 default for Int32 column '#{name}'. Either set the type to Int64 or change the default value."
    else
      " DEFAULT #{default}"
    end
  end

  def default_value(type : Bool.class, default : Bool, name)
    " DEFAULT #{default}"
  end

  def default_value(type : Float.class, default : (Int32 | Int64 | Float), name)
    " DEFAULT #{default.to_f}"
  end

  def column_type(type : String.class)
    "text"
  end

  def column_type(type : Time.class)
    "timestamptz"
  end

  def column_type(type : Int32.class)
    "int"
  end

  def column_type(type : Int64.class)
    "bigint"
  end

  def column_type(type : Bool.class)
    "boolean"
  end

  def column_type(type : Float.class)
    "decimal"
  end

  def column_type(type : Float.class, precision : Int32, scale : Int32)
    "decimal(#{precision},#{scale})"
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
