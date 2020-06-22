# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'attributor/flatpack'

require 'rspec/its'

require 'pry'
require 'pry-byebug'

RSpec.configure do |c|
  # filter_run is short-form alias for filter_run_including
  c.filter_run focus: true
  c.run_all_when_everything_filtered = true
end
