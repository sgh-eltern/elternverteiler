# frozen_string_literal: true

require 'que'
require 'pony'

module SGH
  module Elternverteiler
    # Don't forget to restart the que process after this file was changed.
    class ReachabilityMailJob < Que::Job
      def run(to, subject, body, html_body)
        Pony.mail(
          charset: 'utf-8',
          text_part_charset: 'utf-8',
          from: 'Vorstand Elternbeirat SGH <vorstand@eltern-sgh.de>',
          to: to,
          subject: subject,
          body: body,
          html_body: html_body,
          via: :smtp,
          via_options: {
            address: ENV.fetch('smtp_host'),
            port: ENV.fetch('smtp_port'),
            # tls: !!ENV.fetch('smtp_tls'),
            enable_starttls_auto: true,
            user_name: ENV.fetch('smtp_user'),
            password: ENV.fetch('smtp_password'),
            authentication: ENV.fetch('smtp_authentication'),
            domain: ENV.fetch('smtp_host'),
          }
        )
        finish
      end
    end
  end
end
