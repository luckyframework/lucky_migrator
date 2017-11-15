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

    {% if index %}
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

    IndexDefinition.new(@table_name, column, using, unique).add_to(indices)
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

# Encapsulates the building of an index string.
# Provides an add_to method that accepts a reference to an array and adds the
# index string or raises an exception if already added.
#
# ### Usage
#
# ```
# indices = [] of String
# IndexDefinition.new('users', column: 'email', using: :btree, unique: true).add_to(indices)
# ```
struct IndexDefinition
  def initialize(@table : Symbol, @column : String | Symbol, @using : String | Symbol, @unique = false)
  end

  def to_s
    String.build do |index|
      index << "  CREATE"
      index << " UNIQUE" if @unique
      index << " INDEX #{@table}_#{@column}_index"
      index << " ON #{@table}"
      index << " USING #{@using}"
      index << " (#{@column});"
    end
  end

  def add_to(indices)
    indices.push(to_s) unless added?(indices)
  end

  def added?(indices : Array(String))
    raise "duplicate index on #{@table}.#{@column}" if indices.includes?(to_s)
    raise "duplicate index on #{@table}.#{@column}" if indices.includes?(to_s_without_unique)
    false
  end

  def to_s_without_unique
    to_s.gsub(" UNIQUE", "")
  end
end