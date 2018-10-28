Sequel.migration do
  change do
    create_table(:fächer) do
      primary_key :id

      String :kürzel
      String :name

      DateTime :created_at
      DateTime :updated_at

      constraint(:kürzel_min_length) { Sequel.char_length(:kürzel) > 0 }
      unique :kürzel
      constraint(:name_min_length) { Sequel.char_length(:name) > 0 }
      unique :name
    end
  end
end
