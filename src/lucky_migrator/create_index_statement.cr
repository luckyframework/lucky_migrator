# Builds a sql statement for creating an index using table name, column name,
# index type and unique flag.
#
# ### Usage
#
# ```
# IndexDefinition.new(:users, column: :email, using: :btree, unique: true).build
# # => "  CREATE UNIQUE INDEX users_email_index ON users USING btree (email);"
# ```
class LuckyMigrator::CreateIndexStatement
  ALLOWED_INDEX_TYPES = %w[btree]

  def initialize(@table : Symbol, @column : String | Symbol, @using : String | Symbol, @unique = false)

    raise "index type '#{using}' not supported" unless ALLOWED_INDEX_TYPES.includes?(using.to_s)
  end

  def build
    String.build do |index|
      index << "  CREATE"
      index << " UNIQUE" if @unique
      index << " INDEX #{@table}_#{@column}_index"
      index << " ON #{@table}"
      index << " USING #{@using}"
      index << " (#{@column});"
    end
  end
end
