require 'socket'
require 'yaml'

module Config
  def self.get_config
    raw_config = YAML.load_file('config.yml')
    params = raw_config['default']
    params['rel_paths']['dropbox'] = params['rel_paths']['dropbox'][host_key]
    merge_config(params, raw_config[ENV['RUN_ENV']])
  end

  def self.host_key
    Socket.gethostname.gsub('.', '_').gsub('-', '_').downcase
  end

  def self.merge_config(default, additional)
    additional.each do |key, value|
      if value.is_a?(Hash)
        merge_config(default[key], value)
      else
        default[key] = value
      end
    end
    default
  end
end