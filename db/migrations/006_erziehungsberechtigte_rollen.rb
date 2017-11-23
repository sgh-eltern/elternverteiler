# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:erziehungsberechtigte_rollen) do
      foreign_key :rolle_id, :rollen, null: false, on_delete: :cascade
      foreign_key :erziehungsberechtigter_id, :erziehungsberechtigte, null: false, on_delete: :cascade
      foreign_key :klasse_id, :klasse, null: true, on_delete: :cascade
      primary_key %i[rolle_id erziehungsberechtigter_id ]
      index %i[erziehungsberechtigter_id rolle_id klasse_id]
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
