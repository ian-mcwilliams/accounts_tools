require 'rspec'

require_relative '../../config'
require_relative '../../env'

CONFIG = Config.get_config

RSpec.configure do |config|
  config.filter_run_when_matching :focus
end
