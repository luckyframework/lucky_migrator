module LuckyMigrator
  private PRIMARY_KEY_TO_COLUMN_TYPE_MAPPING = {
    LuckyMigrator::PrimaryKeyType::Serial => Int32,
    LuckyMigrator::PrimaryKeyType::UUID => ::UUID,
  }

  enum PrimaryKeyType
    Serial
    UUID

    def db_type
      PRIMARY_KEY_TO_COLUMN_TYPE_MAPPING[self]
    end
  end
end
