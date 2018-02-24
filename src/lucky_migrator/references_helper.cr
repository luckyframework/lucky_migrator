module LuckyMigrator::ReferencesHelper
  def references(table_name : String | Symbol | Nil, on_delete = :do_nothing)
    if table_name.nil?
      ""
    elsif on_delete == :do_nothing
      " REFERENCES #{table_name}"
    elsif CreateForeignKeyStatement::ALLOWED_ON_DELETE_STRATEGIES.includes?(on_delete)
      " REFERENCES #{table_name}" + " ON DELETE " + "#{on_delete}".upcase
    else
      raise "on_delete: :#{on_delete} is not supported. Please use :do_nothing, :cascade, :restrict, or :nullify"
    end
  end
end
