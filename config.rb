require 'socket'
require 'yaml'

module Config
  def self.get_config
    raw_config = YAML.load_file('config.yml')
    params = raw_config['default']
    host_key = Socket.gethostname.gsub('.', '_').gsub('-', '_').downcase
    params.merge(raw_config[host_key])
  end
end