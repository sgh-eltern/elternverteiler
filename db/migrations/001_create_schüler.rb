Sequel.migration do
  change do
    create_table(:schüler) do
      primary_key :id
      String :nachname, null: false
      String :vorname, null: false
      String :klasse, null: false
      DateTime :created_at
      DateTime :updated_at

      constraint(:nachname_min_length) { Sequel.char_length(:nachname) > 0 }
      constraint(:vorname_min_length) { Sequel.char_length(:vorname) > 0 }
    end
  end
end
