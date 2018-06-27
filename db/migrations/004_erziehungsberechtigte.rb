Sequel.migration do
  change do
    create_table(:erziehungsberechtigte) do
      primary_key :id
      String :nachname
      String :vorname
      String :mail
      String :telefon
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
