require 'socket'
require 'yaml'

module Config
  def self.get_config
    raw_config = YAML.load_file('config.yml')
    params = raw_config['default']
    params['rel_paths']['dropbox'] = params['rel_paths']['dropbox'][host_key]
    params = merge_config(params, raw_config[ENV['RUN_ENV']])
    params['accounting_periods'] ||= (0..9).to_a.map { '' }
    params['accounting_period_filepaths'] = params['accounting_periods'].map.with_index(1) do |item, i|
      "#{ENV['TOOL_ROOT']}#{params['rel_paths']['dropbox']}#{params['rel_paths']['livecorp']}#{item}Accounts#{i}.xlsx"
    end
    params
  end

  def self.host_key
    Socket.gethostname.gsub('.', '_').gsub('-', '_').downcase
  end

  def self.merge_config(default, additional)
    additional.each do |key, value|
      value.is_a?(Hash) ? merge_config(default[key], value) : default[key] = value
    end
    default
  end
end