module LuckyMigrator::ColumnDefaultHelpers
  alias ColumnDefaultType = String | Time | Int32 | Int64 | Float32 | Float64 | Bool | Symbol

  def default_value(type : String.class, default : String)
    " DEFAULT '#{default}'"
  end

  def default_value(type : Int64.class, default : Int32 | Int64)
    " DEFAULT #{default}"
  end

  def default_value(type : Int32.class, default : Int32)
    " DEFAULT #{default}"
  end

  def default_value(type : Bool.class, default : Bool)
    " DEFAULT #{default}"
  end

  def default_value(type : Float.class, default : Float)
    " DEFAULT #{default}"
  end

  def default_value(type : Time.class, default : Time)
    " DEFAULT '#{default.to_utc}'"
  end

  def default_value(type : Time.class, default : Symbol)
    if default == :now
      " DEFAULT NOW()"
    else
      raise "Unrecognized default value #{default} for a timestamptz. Please use :now for current timestamp."
    end
  end
end
