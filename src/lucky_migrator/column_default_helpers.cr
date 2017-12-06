module LuckyMigrator::ColumnDefaultHelpers
  alias ColumnDefaultType = String | Time | Int32 | Int64 | Float32 | Float64 | Bool | Symbol

  def value_to_string(value : String | Time)
    "'#{value}'"
  end

  def value_to_string(value : Int32 | Int64 | Float | Bool)
    "#{value}"
  end

  def default_value(type : String.class, default : String)
    " DEFAULT #{value_to_string(default)}"
  end

  def default_value(type : Int64.class, default : Int32 | Int64)
    " DEFAULT #{value_to_string(default)}"
  end

  def default_value(type : Int32.class, default : Int32)
    " DEFAULT #{value_to_string(default)}"
  end

  def default_value(type : Bool.class, default : Bool)
    " DEFAULT #{value_to_string(default)}"
  end

  def default_value(type : Float.class, default : Float)
    " DEFAULT #{value_to_string(default)}"
  end

  def default_value(type : Time.class, default : Time)
    " DEFAULT #{value_to_string(default.to_utc)}"
  end

  def default_value(type : Time.class, default : Symbol)
    if default == :now
      " DEFAULT NOW()"
    else
      raise "Unrecognized default value #{default} for a timestamptz. Please use :now for current timestamp."
    end
  end
end
