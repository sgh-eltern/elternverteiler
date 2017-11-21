Sequel.migration do
  change do
    create_table(:erziehungsberechtigung) do
      foreign_key :schüler_id, :schüler, null: false, on_delete: :cascade
      foreign_key :erziehungsberechtigter_id, :erziehungsberechtigte, null: false, on_delete: :cascade
      primary_key [:schüler_id, :erziehungsberechtigter_id]
      index [:erziehungsberechtigter_id, :schüler_id]
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
