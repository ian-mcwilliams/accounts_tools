ENV['RUN_ENV'] = 'test'
ENV['TOOL_ROOT'] = 'convert_bank_extract/'

require_relative '../../env'

require_relative 'support/convert_bank_extract_spec_helpers'
require 'rspec'
require 'rxl'

RSpec.configure do |config|
  config.filter_run_when_matching :focus
end
