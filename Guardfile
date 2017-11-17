# frozen_string_literal: true

guard :bundler do
  require 'guard/bundler'
  require 'guard/bundler/verify'
  helper = Guard::Bundler::Verify.new
  files = ['Gemfile']
  files += Dir['*.gemspec'] if files.any? { |f| helper.uses_gemspec?(f) }
  files.each { |file| watch(helper.real_path(file)) }
end

%w[unit system acceptance].each do |type|
  group type do
    guard :rspec, cmd: 'bundle exec rspec' do
      watch(%r{^spec/#{type}/.+_spec\.rb$})
      watch(%r{^lib/(?<module>.*/)(?<file>.+)\.rb$}) { |m|
        "spec/unit/#{m[:module]}#{m[:file]}_spec.rb"
      }
      watch('spec/spec_helper.rb') { 'spec' }
    end
  end
end
