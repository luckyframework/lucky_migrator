class LuckyMigrator::AlterTableStatement
  getter statement = IO::Memory.new
  getter rows = [] of String
  getter dropped_rows = [] of String

  def initialize(@table_name : Symbol)
  end

  def build
    statement << "ALTER TABLE #{@table_name}"
    statement << "\n"
    with self yield
    process_rows
    statement.to_s
  end

  private def process_rows
    statement << (rows + dropped_rows).join(",\n")
  end

  macro add(type_declaration)
    {% if type_declaration.type.is_a?(Union) %}
      add_column :{{ type_declaration.var }}, {{ type_declaration.type.types.first }}, optional: true
    {% else %}
      add_column :{{ type_declaration.var }}, {{ type_declaration.type }}
    {% end %}
  end

  def add_column(name : Symbol, type : (Bool | String | Time | Int32 | Int64 | Float).class, optional = false)
    rows << String.build do |row|
      row << "  ADD "
      row << name.to_s
      row << " "
      row << column_type(type)
      row << null_fragment(optional)
    end
  end

  def remove(name : Symbol)
    dropped_rows << "  DROP #{name.to_s}"
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
