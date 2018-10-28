Sequel.migration do
  change do
    create_table(:unterrichtet) do
      foreign_key :lehrer_id, :lehrer, null: false, on_delete: :cascade
      foreign_key :fach_id, :fächer, null: false, on_delete: :cascade
      primary_key [:lehrer_id, :fach_id]
      index [:fach_id, :lehrer_id]
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
