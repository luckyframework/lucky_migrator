# Builds an SQL statement for dropping an index by inferring it's name using table name and column.
#
# ### Usage
#
# ```
# DropIndexStatement.new(:users, :email).build
# # => "DROP INDEX users_email_index;"
# ```
class LuckyMigrator::DropIndexStatement
  ALLOWED_INDEX_TYPES = %w[btree]

  def initialize(@table : Symbol, @column : Symbol)
  end

  def build
    String.build do |index|
      index << "DROP"
      index << " INDEX #{@table}_#{@column}_index;"
    end
  end
end
