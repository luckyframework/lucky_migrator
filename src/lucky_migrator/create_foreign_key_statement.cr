# Generates an ALTER TABLE statement for adding a foreign key constraint on a table.
#
# ### Usage
#
# ```
# CreateForeignKeyStatement.new(from: :comments, to: :users, column: :author_id, primary_key: :uid, on_delete: :cascade).build
# # => "ALTER TABLE comments ADD CONSTRAINT comments_author_id_fk FOREIGN KEY (author_id) REFERENCES users (uid) ON DELETE CASCADE;"
# ```
class LuckyMigrator::CreateForeignKeyStatement
  ALLOWED_ON_DELETE_STRATEGIES = %i[cascade restrict nullify]

  def initialize(@from : Symbol, @to : Symbol, @on_delete : Symbol, @column : Symbol? = nil, @primary_key = :id)
  end

  def build
    foreign_key = @column || LuckyInflector::Inflector.singularize(@to.to_s) + "_id"
    String.build do |index|
      index << "ALTER TABLE"
      index << " #{@from}"
      index << " ADD CONSTRAINT #{@from}_#{foreign_key}_fk"
      index << " FOREIGN KEY (#{foreign_key})"
      index << " REFERENCES #{@to} (#{@primary_key})"
      index << on_delete_strategy(@on_delete)
      index << ";"
    end
  end

  def on_delete_strategy(strategy : Symbol)
    if ALLOWED_ON_DELETE_STRATEGIES.includes?(strategy)
      return " ON DELETE" + " #{strategy}".upcase
    elsif strategy == :do_nothing
      return ""
    else
      raise "on_delete: :#{strategy} is not supported. Please use :do_nothing, :cascade, :restrict, or :nullify"
    end
  end
end
