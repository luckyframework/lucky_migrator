class LuckyMigrator::CreateTableStatement
  getter statement = IO::Memory.new
  getter rows = [] of String
  getter indexes = [] of String

  ALLOWED_INLINE_INDEXES = %w[btree]

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
    process_indexes
    statement.to_s
  end

  private def process_rows
    statement << rows.join(",\n")
  end

  private def process_indexes
    return if indexes.empty?
    statement << "\n"
    statement << indexes.join("\n")
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

  def add_index(column_name : String, unique = false, using = "btree")
    raise "index type '#{using}' not supported" unless ALLOWED_INLINE_INDEXES.includes?(using)

    index_str = "CREATE"
    index_str += " UNIQUE" if unique
    index_str += " INDEX #{@table_name}_#{column_name}_index ON #{@table_name} USING #{using} (#{column_name});"
    indexes.push(index_str)
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
