require_relative 'db'
require 'sequel'
require 'que'
Que.connection = Sequel::Model.db
require 'sgh/elternverteiler/jobs/reachability_mail_job'
