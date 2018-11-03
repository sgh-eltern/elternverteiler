require 'que'

Sequel.migration do
  up do
    if postgres?
      Que.connection = self
      Que.migrate! :version => 4
    end
  end

  down do
    if postgres?
      Que.connection = self
      Que.migrate! :version => 0
    end
  end
end

def postgres?
  if adapter_scheme == :postgres
    true
  else
    warn "NOT migrating Que tables because schema '#{adapter_scheme}' is not ':postgres'"
    false
  end
end
