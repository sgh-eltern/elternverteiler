# frozen_string_literal: true

require 'net/ssh'
require 'net/scp'
require 'pathname'

module SGH
  module Elternverteiler
    class ListServer
      def initialize(server:, user:, private_key:)
        @server = server
        @user = user
        @private_key = private_key
      end

      def upload(content, file_name='elternverteiler.txt')
        Net::SSH.start(@server, @user, key_data: @private_key, keys_only: true) do |ssh|
          ssh.scp.upload!(StringIO.new(content), file_name)
        end
      end

      def download(file_name='elternverteiler.txt')
        Net::SSH.start(@server, @user, key_data: @private_key, keys_only: true) do |ssh|
          ssh.scp.download!(file_name)
        end
      end
    end
  end
end
