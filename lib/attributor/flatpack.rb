require 'attributor'

require 'attributor/flatpack/version'
require 'attributor/flatpack/config_dsl_compiler'

require 'attributor/flatpack/config'
require 'attributor/flatpack/undefined_key'
Dir["attributor/flatpack/types/*.rb"].each {|file| require file }

module Attributor
  module Flatpack
  end
end
