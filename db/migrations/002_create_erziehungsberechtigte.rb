Sequel.migration do
  change do
    create_table(:erziehungsberechtigte) do
      primary_key :id
      String :nachname, null: false
      String :vorname
      String :mail
      String :telefon
      DateTime :created_at
      DateTime :updated_at

      constraint(:nachname_min_length) { Sequel.char_length(:nachname) > 0 }
    end
  end
end
