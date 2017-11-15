class LuckyMigrator::CreateTableStatement
  getter statement = IO::Memory.new
  getter rows = [] of String
  getter indices = [] of String

  ALLOWED_INDEX_TYPES = %w[btree]

  def initialize(@table_name : Symbol)
  end

  def build
    statement << <<-SQL
    CREATE TABLE #{@table_name} (
      id serial PRIMARY KEY,
      created_at timestamp NOT NULL,
      updated_at timestamp NOT NULL,
    SQL
    statement << "\n"
    with self yield
    process_rows
    statement << ")"
    process_indices
    statement.to_s
  end

  private def process_rows
    statement << rows.join(",\n")
  end

  private def process_indices
    return if indices.empty?
    statement << "\n"
    statement << indices.join("\n")
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
    raise "index type '#{using}' not supported" unless ALLOWED_INDEX_TYPES.includes?(using.to_s)

    index = IndexDefinition.new(@table_name, column, using, unique).build
    indices << index unless index_added?(index, column)
  end

  # Returns false unless matching index exists. Ignores UNIQUE
  def index_added?(index : String, column : String | Symbol)
    return false unless indices.includes?(index) || indices.includes?(index.gsub(" UNIQUE", ""))
    raise "index on #{@table_name}.#{column} already exists"
    raise "index on #{@table_name}.#{column} already exists"
  end

  def column_type(type : String.class)
    "text"
  end

  def column_type(type : Time.class)
    "timestamp"
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
