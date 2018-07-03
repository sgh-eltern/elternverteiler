require 'shellwords'

module PostgresHelpers
  #
  # Create a new Postgres database with the given name
  #
  def self.create_db(name)
    %x(createdb #{Shellwords.escape(name)})
    raise "Creating the Postgres database #{name} failed" unless $CHILD_STATUS.success?
  end

  #
  # Drop the Postgres database with the given name
  #
  def self.drop_db(name)
    %x(dropdb #{Shellwords.escape(name)})
    raise "Dropping the Postgres database #{name} failed" unless $CHILD_STATUS.success?
  end
end
