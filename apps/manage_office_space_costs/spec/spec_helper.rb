ENV['RUN_ENV'] = 'test'
ENV['TOOL_ROOT'] = 'apps/manage_office_space_costs/'

require_relative '../../../env'
require_relative '../../../config'

require 'rspec'
require 'rxl'

CONFIG = Config.get_config

RSpec.configure do |config|
  config.filter_run_when_matching :focus
end
