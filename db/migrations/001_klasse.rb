Sequel.migration do
  change do
    create_table(:klasse) do
      primary_key :id
      String :stufe, null: false
      String :zug, null: false
      DateTime :created_at
      DateTime :updated_at

      constraint(:stufe_min_length) { Sequel.char_length(:stufe) > 0 }
      constraint(:zug_min_length) { Sequel.char_length(:zug) > 0 }
    end
  end
end