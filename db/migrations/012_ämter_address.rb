# frozen_string_literal: true

Sequel.migration do
  up do
    add_column :ämter, :mail, String
    from(:ämter).update(mail: 'TODO')
    alter_table(:ämter) do
      add_constraint(:mail_min_length) { Sequel.char_length(:mail) > 0 }
    end
  end

  down do
    alter_table(:ämter) { drop_constraint(:mail_min_length) }
    drop_column :ämter, :mail
  end
end
