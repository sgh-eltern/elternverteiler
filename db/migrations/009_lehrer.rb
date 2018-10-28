Sequel.migration do
  change do
    create_table(:lehrer) do
      primary_key :id
      String :titel
      String :nachname
      String :vorname
      String :email
      String :kürzel
      DateTime :created_at
      DateTime :updated_at

      constraint(:kürzel_min_length) { Sequel.char_length(:kürzel) > 1 }
      unique :kürzel

      constraint(:nachname_min_length) { Sequel.char_length(:nachname) > 0 }
      constraint(:vorname_min_length) { Sequel.char_length(:vorname) > 0 }
      # duplicates of Vorname, Nachname are allowed
    end
  end
end
