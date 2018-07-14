module LuckyMigrator
  enum PrimaryKeyType
    Serial
    UUID

    def db_type
      if self == UUID
        ::UUID
      else
        Int32
      end
    end
  end
end
