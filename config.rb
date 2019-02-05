require 'socket'
require 'yaml'

module Config
  def self.get_config
    raw_config = YAML.load_file('config.yml')
    params = raw_config['default']
    params['dropbox_path'] = params['dropbox_path'][host_key]
    params.merge(raw_config[ENV['RUN_ENV']])
  end

  def self.host_key
    Socket.gethostname.gsub('.', '_').gsub('-', '_').downcase
  end
end