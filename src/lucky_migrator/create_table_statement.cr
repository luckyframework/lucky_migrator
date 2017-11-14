class LuckyMigrator::CreateTableStatement
  getter statement = IO::Memory.new
  getter rows = [] of String
  getter indexes = [] of String
  getter table_name : Symbol

  def initialize(@table_name : Symbol)
    table_name = @table_name
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
    statement << ")\n"
    add_indexes
    statement.to_s
  end

  private def process_rows
    statement << rows.join(",\n")
  end

  private def add_indexes
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
      %index_str = "CREATE"
      {% if unique %}
        %index_str += " UNIQUE"
      {% end %}
      %index_str += " INDEX #{table_name}_{{ type_declaration.var }}_index ON #{table_name} USING {{ using.id }} ({{ type_declaration.var }});"
      indexes.push(%index_str)
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
