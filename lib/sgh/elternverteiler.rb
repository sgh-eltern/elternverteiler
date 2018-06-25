# frozen_string_literal: true

require 'sequel'
Sequel::Model.plugin :timestamps

require 'sgh/elternverteiler/mailing_list'

module SGH
  module Elternverteiler
    class Klasse < Sequel::Model(:klasse); end
    class Amtsperiode < Sequel::Model(:amtsperioden); end
    class Rolle < Sequel::Model(:rollen); end
    class Schüler < Sequel::Model(:schüler); end
    class Erziehungsberechtigter < Sequel::Model(:erziehungsberechtigte); end
    class Erziehungsberechtigung < Sequel::Model(:erziehungsberechtigung); end

    def self.elternbeirat
      Rolle.where(name: ['1.EV', '2.EV']).
        map(&:mitglieder).
        flatten.
        sort_by(&:nachname).
        tap do |all|
        all.define_singleton_method(:mailing_list) do
          MailingList.new(
            name: 'Elternbeirat',
            address: 'elternbeirat',
            members: all
          )
        end
      end
    end

    def self.elternbeiratsvorsitzende
      Rolle.where(name: ['1.EBV', '2.EBV']).
        map(&:mitglieder).
        flatten.
        sort_by(&:nachname).
        tap do |all|
        all.define_singleton_method(:mailing_list) do
          MailingList.new(
            name: 'Elternbeiratsvorsitzende',
            address: 'elternbeiratsvorsitzende',
            members: all
          )
        end
      end
    end

    def self.elternvertreter_schulkonferenz
      Rolle.where(name: ['SK', 'SKV']).
        map(&:mitglieder).
        flatten.
        sort_by(&:nachname).
        tap do |all|
        all.define_singleton_method(:mailing_list) do
          MailingList.new(
            name: 'Elternvertreter in der Schulkonferenz',
            address: 'elternvertreter-schulkonferenz',
            members: all
          )
        end
      end
    end
  end
end

require 'sgh/elternverteiler/forme_helper'
require 'sgh/elternverteiler/klasse'
require 'sgh/elternverteiler/rolle'
require 'sgh/elternverteiler/schüler'
require 'sgh/elternverteiler/erziehungsberechtigung'
require 'sgh/elternverteiler/erziehungsberechtigter'
require 'sgh/elternverteiler/amtsperiode'
