# frozen_string_literal: true

module SGH
  module Elternverteiler
    MailingList = Struct.new(:title, :address, :members, keyword_init: true) do
      def address
        "#{self[:address]}@schickhardt-gymnasium-herrenberg.de"
      end
    end
  end
end
