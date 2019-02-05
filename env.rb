require_relative 'config'

ENV['RUN_ENV'] ||= 'prod'

CONFIG = Config.get_config

ENV['BOOKKEEPING_PATH'] = "#{CONFIG['rel_livecorp_path']}#{CONFIG['bookkeeping_path']}"
ENV['CONTRACTS_FILEPATH'] = "#{ENV['BOOKKEEPING_PATH']}#{CONFIG['contracts_filename']}"
ENV['SALES_AND_VAT_FILEPATH'] = "#{ENV['BOOKKEEPING_PATH']}#{CONFIG['sales_and_vat_filename']}"
