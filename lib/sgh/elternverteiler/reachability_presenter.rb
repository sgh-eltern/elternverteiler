# frozen_string_literal: true

require 'tilt'
require 'erb'
require 'pandoc-ruby'

module SGH
  module Elternverteiler
    class ReachabilityPresenter
      def initialize(template_path)
        @erb_template = Tilt.new(template_path)
      end

      def jobs
        Klasse.map do |klasse|
          unreachable = klasse.schüler.select { |sch| sch.eltern.collect(&:mail).compact.reject(&:empty?).empty? }.sort_by(&:nachname)
          subject = if unreachable.count.zero?
            "Alle Schüler der #{klasse} per eMail erreichbar"
          else
            "#{unreachable.count} Schüler der #{klasse} nicht per eMail erreichbar"
          end

          to = "#{klasse.elternvertreter.mailing_list.name} <#{klasse.elternvertreter.mailing_list.address(:long)}>"

          erb_body = @erb_template.render(
            self,
            klasse: klasse,
            unreachable: unreachable
          )

          {
            to: to,
            subject: subject,
            body: PandocRuby.convert(erb_body, from: :markdown, to: :plain),
            html_body: PandocRuby.convert(erb_body, from: :markdown, to: :html),
          }
        end
      end
    end
  end
end
