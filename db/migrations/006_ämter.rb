# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:ämter) do
      primary_key :id
      String :name, null: false
      DateTime :created_at
      DateTime :updated_at

      constraint(:name_min_length) { Sequel.char_length(:name) > 0 }
      unique :name
    end
  end
end
