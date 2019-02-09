ENV['RUN_ENV'] = 'test'
ENV['TOOL_ROOT'] = 'tax_management/'

require_relative '../../env'

require_relative 'support/tax_checker_spec_helpers'
require 'awesome_print'
require 'rspec'

# RSpec.configure do |config|
#   config.treat_symbols_as_metadata_keys_with_true_values = true
# end
