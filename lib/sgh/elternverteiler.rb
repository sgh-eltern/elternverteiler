# frozen_string_literal: true

require 'sequel'
Sequel::Model.plugin :timestamps

require 'sgh/elternverteiler/mailing_list'

module SGH
  module Elternverteiler
    class Klasse < Sequel::Model(:klasse); end
    class Klassenstufe < Sequel::Model(:klassenstufe); end
    class Amtsperiode < Sequel::Model(:amtsperioden); end
    class Amt < Sequel::Model(:ämter); end
    class Schüler < Sequel::Model(:schüler); end
    class Erziehungsberechtigter < Sequel::Model(:erziehungsberechtigte); end
    class Erziehungsberechtigung < Sequel::Model(:erziehungsberechtigung); end
    class Fach < Sequel::Model(:fächer); end
    class Lehrer < Sequel::Model(:lehrer); end

    def self.elternbeirat
      Amt.where(name: ['1.EV', '2.EV']).
        map(&:inhaber).
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
      Amt.where(name: ['1.EBV', '2.EBV']).
        map(&:inhaber).
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
      Amt.where(name: ['1.EBV', 'SK', 'SKV']).
        map(&:inhaber).
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

    def self.delegierte_gesamtelternbeirat
      Amt.where(name: 'GEB-Delegierte').
        map(&:inhaber).
        flatten.
        sort_by(&:nachname).
        tap do |all|
        all.define_singleton_method(:mailing_list) do
          MailingList.new(
            name: 'GEB-Delegierte',
            address: 'geb-delegierte',
            members: all
          )
        end
      end
    end
  end
end

require 'sgh/elternverteiler/forme_helper'
require 'sgh/elternverteiler/klasse'
require 'sgh/elternverteiler/klassenstufe'
require 'sgh/elternverteiler/amt'
require 'sgh/elternverteiler/schüler'
require 'sgh/elternverteiler/erziehungsberechtigung'
require 'sgh/elternverteiler/erziehungsberechtigter'
require 'sgh/elternverteiler/amtsperiode'
require 'sgh/elternverteiler/lehrer'
require 'sgh/elternverteiler/fach'
require 'sgh/elternverteiler/lehrer'
