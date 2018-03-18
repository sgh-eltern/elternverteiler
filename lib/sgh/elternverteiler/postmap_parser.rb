# frozen_string_literal: true

module SGH
  module Elternverteiler
    class PostmapParser
      def parse(contents)
        contents.lines.
          reject(&:empty?).
          reject { |line| line.start_with?('#') }.
          inject({}) do |db, line|
          name, addresses = line.split(' ')
          db[name] = addresses.split(',').sort if addresses
          db
        end
      end
    end
  end
end
