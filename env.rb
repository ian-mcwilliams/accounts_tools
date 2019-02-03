require_relative 'config'

ENV['RUN_ENV'] ||= 'prod'

CONFIG = Config.get_config

ENV['BOOKKEEPING_PATH'] = "#{CONFIG['rel_livecorp_path']}#{CONFIG['bookkeeping_path']}"
