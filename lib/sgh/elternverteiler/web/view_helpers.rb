module SGH
  module Elternverteiler
    module Web
      module PathHelpers
        def klasse_path(klasse)
          "/klassen/#{klasse.name.downcase}"
        end

        def link_to(klasse)
          %Q(<a href="#{klasse_path(klasse)}">#{klasse.name}</a>)
        end
      end
    end
  end
end
