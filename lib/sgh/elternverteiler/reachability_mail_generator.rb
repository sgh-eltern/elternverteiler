# frozen_string_literal: true

require 'tilt'
require 'erb'
require 'pandoc-ruby'
require 'sgh/elternverteiler'

module SGH
  module Elternverteiler
    class ReachabilityMailGenerator
      def initialize(template_path)
        Klasse.each do |klasse|
          unreachable = klasse.schüler.select { |sch| sch.eltern.collect(&:mail).compact.reject(&:empty?).empty? }.sort_by(&:nachname)
          subject = if unreachable.count.zero?
                      "Alle Schüler der #{klasse} per eMail erreichbar"
                    else
                      "#{unreachable.count} Schüler der #{klasse} nicht per eMail erreichbar"
          end

          to = "#{klasse.elternvertreter.mailing_list.name} <#{klasse.elternvertreter.mailing_list.address(:long)}>"

          erb_body = Tilt.new(template_path).render(
            self,
            klasse: klasse,
            unreachable: unreachable
          )

          yield to,
                subject,
                PandocRuby.convert(erb_body, from: :markdown, to: :plain),
                PandocRuby.convert(erb_body, from: :markdown, to: :html)
        end
      end
    end
  end
end
