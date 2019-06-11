# frozen_string_literal: true

module SGH
  module Elternverteiler
    class VCardPresenter
      def present(exhibit)
        address = if exhibit.respond_to?(:address)
                    exhibit.address(:long)
                  else
                    exhibit.mail
                  end

        <<~HEREDOC.chomp
          BEGIN:VCARD
          VERSION:3.0
          EMAIL;TYPE=work,pref:#{address}
          FN:#{exhibit.name}
          ORG:Schickhardt-Gymnasium Herrenberg
          REV:#{exhibit.updated_at rescue Time.now.iso8601}
          END:VCARD
        HEREDOC
      end
    end
  end
end
