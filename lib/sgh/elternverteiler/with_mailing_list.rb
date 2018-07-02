# frozen_string_literal: true

module SGH
  module Elternverteiler
    # TODO: Each arg can either be
    # - a symbol => name of the method to send to self in order to get the value,
    # - a string => the value itself
    # - or a proc => call it with self as argument in order to get the value
    module WithMailingList
      def with_mailing_list(name:, address:, members:)
        define_method :mailing_list do
          MailingList.new(
            name: name.call(self),
            address: address.call(self),
            members: self.send(members)
          )
        end
      end
    end
  end
end
