class LuckyMigrator::CreateTableStatement
  getter statements = [] of String
  getter rows = [] of String
  getter table_statement = ""
  getter index_statements = [] of String

  def initialize(@table_name : Symbol)
  end

  # Accepts a block to build a table and indices using `add` and `add_index` methods.
  #
  # The generated sql statements are aggregated in the statements getter, and the
  # table_statement and index_statements are available individually as getters.
  #
  # # Usage
  #
  # ```
  # built = LuckyMigrator::CreateTableStatement.new(:users).build do
  #   add :email : String, unique: true
  # end
  #
  # built.table_statement
  # #=> "CREATE TABLE users (
  #         id serial PRIMARY KEY,
  #         created_at timestamp NOT NULL,
  #         updated_at timestamp NOT NULL,
  #         email text NOT NULL);",
  #
  # built.index_statements
  # #=> ["  CREATE UNIQUE INDEX users_email_index ON users USING btree (email);"]
  #
  # build.statements
  # # => [
  #   "CREATE TABLE users (
  #     id serial PRIMARY KEY,
  #     created_at timestamp NOT NULL,
  #     updated_at timestamp NOT NULL,
  #     email text NOT NULL);",
  #   "  CREATE UNIQUE INDEX users_email_index ON users USING btree (email);"
  # ]
  #```
  def build
    with self yield

    build_table_statement
    build_index_statements

    self
  end

  # Join rows into table_statment and push into statements array
  private def build_table_statement
    statement = IO::Memory.new
    statement << initial_table_statement
    statement << "\n"

    statement << rows.join(",\n")
    statement << ");"

    @table_statement = statement.to_s

    statements.push(table_statement)
  end

  private def initial_table_statement
    <<-SQL
    CREATE TABLE #{@table_name} (
      id serial PRIMARY KEY,
      created_at timestamptz NOT NULL,
      updated_at timestamptz NOT NULL,
    SQL
  end

  # Push index_statements into statements array
  private def build_index_statements
    return if index_statements.empty?
    index_statements.each { |index| statements.push(index) }
  end

  # Generates raw sql from a type declaration and options passed in as named
  # variables.
  macro add(type_declaration, index = false, using = "btree", unique = false)
    {% if type_declaration.type.is_a?(Union) %}
      add_column :{{ type_declaration.var }}, {{ type_declaration.type.types.first }}, optional: true
    {% else %}
      add_column :{{ type_declaration.var }}, {{ type_declaration.type }}
    {% end %}

    {% if index || unique %}
      add_index "{{ type_declaration.var }}", using: {{ using }}, unique: {{ unique }}
    {% end %}
  end

  def add_column(name, type : (String | Time | Int32 | Int64 | Float | Bool).class, optional = false)
    rows << String.build do |row|
      row << "  "
      row << name.to_s
      row << " "
      row << column_type(type)
      row << null_fragment(optional)
    end
  end

  # Generates raw sql for adding an index to a table column. Accepts 'unique' and 'using' options.
  def add_index(column : String | Symbol, unique = false, using : String | Symbol = "btree")
    index = CreateIndexStatement.new(@table_name, column, using, unique).build
    index_statements << index unless index_added?(index, column)
  end

  # Returns false unless matching index exists. Ignores UNIQUE
  def index_added?(index : String, column : String | Symbol)
    return false unless index_statements.includes?(index) || index_statements.includes?(index.gsub(" UNIQUE", ""))
    raise "index on #{@table_name}.#{column} already exists"
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

  def column_type(type : Float.class)
    "decimal"
  end

  def column_type(type : Bool.class)
    "boolean"
  end

  def null_fragment(optional)
    if optional
      ""
    else
      " NOT NULL"
    end
  end
end
