# Generates an ALTER TABLE statement for adding a foreign key constraint on a table.
#
# ### Usage
#
# ```
# CreateForeignKeyStatement.new(from: :comments, to: :users, column: :author_id, primary_key: :uid, on_delete: :cascade).build
# # => "ALTER TABLE comments ADD CONSTRAINT comments_author_id_fk FOREIGN KEY (author_id) REFERENCES users (uid) ON DELETE CASCADE;"
# ```
class LuckyMigrator::CreateForeignKeyStatement
  def initialize(@from : Symbol, @to : Symbol, @column : Symbol? = nil, @primary_key = :id, @on_delete = :no_action)
  end

  def build
    foreign_key = @column || singularize(@to.to_s) + "_id"
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

  def singularize(word : String)
    if word.ends_with?("ies")
      return word.rchop("ies") + "y"
    elsif word.ends_with?("s")
      return word.rchop
    else
      return word
    end
  end

  def on_delete_strategy(strategy : Symbol)
    if %i[cascade restrict nullify].includes?(strategy)
      return " ON DELETE" + " #{strategy}".upcase
    elsif strategy == :no_action
      return ""
    else
      raise "on_delete: :#{strategy} is not supported. Please use :cascade, :restrict, or :nullify"
    end
  end
end
