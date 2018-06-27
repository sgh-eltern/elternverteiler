# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:mailing_list) do
      primary_key :id
      String :name, null: false
      String :address, null: false

      DateTime :created_at
      DateTime :updated_at

      constraint(:name_min_length) { Sequel.char_length(:name) > 0 }
      unique :name

      constraint(:address_min_length) { Sequel.char_length(:address) > 0 }
      unique :address
    end
  end
end
