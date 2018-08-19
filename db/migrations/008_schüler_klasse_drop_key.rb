Sequel.migration do
  up do
    alter_table(:schüler) do
      drop_foreign_key :klasse_id
      add_foreign_key :klasse_id, :klasse, on_delete: :cascade
      set_column_not_null(:klasse_id)
    end
  end

  down do
    alter_table(:schüler) do
      drop_foreign_key :klasse_id
      add_foreign_key :klasse_id, :klasse, null: false
    end
  end
end
