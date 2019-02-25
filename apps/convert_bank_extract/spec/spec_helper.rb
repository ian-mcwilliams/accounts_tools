ENV['RUN_ENV'] = 'test'
ENV['TOOL_ROOT'] = 'apps/convert_bank_extract/'

require_relative '../../../env'
require_relative '../../../config'

require_relative 'support/convert_bank_extract_spec_helpers'
require 'rspec'
require 'rxl'

CONFIG = Config.get_config

RSpec.configure do |config|
  config.filter_run_when_matching :focus
end
