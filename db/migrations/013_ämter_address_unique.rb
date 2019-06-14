# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:ämter) { add_unique_constraint(:mail, name: :unique_mail) }
  end

  down do
    alter_table(:ämter) { drop_constraint(:unique_mail) }
  end
end
