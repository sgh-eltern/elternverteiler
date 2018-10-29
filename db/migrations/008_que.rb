require 'que'

Sequel.migration do
  up do
    if adapter_scheme == :postgres
      Que.connection = self
      Que.migrate! :version => 3
    end
  end

  down do
    if adapter_scheme == :postgres
      Que.connection = self
      Que.migrate! :version => 0
    end
  end
end
