# frozen_string_literal: true

module SGH
  module Elternverteiler
    class VCardPresenter
      def present(exhibit)
        <<~HEREDOC.chomp
          BEGIN:VCARD
          VERSION:3.0
          EMAIL;TYPE=work,pref:#{exhibit.address(:long)}
          FN:#{exhibit.name}
          END:VCARD
        HEREDOC
      end
    end
  end
end
