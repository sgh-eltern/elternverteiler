# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:amtsperioden) do
      primary_key %i[rolle_id inhaber_id klasse_id]
      foreign_key :rolle_id, :rollen, null: false, on_delete: :cascade
      foreign_key :inhaber_id, :erziehungsberechtigte, null: false, on_delete: :cascade
      foreign_key :klasse_id, :klasse, null: true, on_delete: :cascade
      index %i[inhaber_id rolle_id klasse_id]
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
