# Builds an SQL statement for changing a columns NOT NULL status.
#
# ### Usage
#
# ```
# ChangeNullStatement.new(:users, :email, make: :optional).build
# # => "ALTER TABLE users ALTER COLUMN email DROP NOT NULL;"
# ```
class LuckyMigrator::ChangeNullStatement
  ALLOWED_MAKE_OPTIONS = [:optional, :required]

  def initialize(@table : Symbol, @column : Symbol, @make : Symbol)
    unless ALLOWED_MAKE_OPTIONS.includes?(make)
      raise "make ':#{make}' not supported. Please use :optional or :required."
    end
  end

  def build
    if @make == :optional
      change = "DROP"
    else
      change = "SET"
    end

    String.build do |index|
      index << "ALTER TABLE #{@table}"
      index << " ALTER COLUMN #{@column}"
      index << " #{change} NOT NULL;"
    end
  end
end
