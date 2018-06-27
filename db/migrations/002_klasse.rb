Sequel.migration do
  change do
    create_table(:klasse) do
      primary_key :id
      foreign_key :stufe_id, :klassenstufe, null: false
      String :zug
      DateTime :created_at
      DateTime :updated_at

      constraint(:zug_min_length) { Sequel.char_length(:zug) > 0 }
      unique [:stufe_id, :zug]
    end
  end
end
