# frozen_string_literal: true

module SGH
  module Elternverteiler
    module Web
      module PathHelpers
        def klasse_path(klasse)
          "/klassen/#{klasse.name.downcase}"
        end

        def klassenstufe_path(klassenstufe)
          "/klassenstufen/#{klassenstufe.name.downcase}"
        end

        def link_to(klasse)
          %(<a href="#{klasse_path(klasse)}">#{klasse.name}</a>)
        end

        def amt_path(amt)
          "/ämter/#{amt.id}"
        end
      end
    end
  end
end
