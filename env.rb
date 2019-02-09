require_relative 'config'

ENV['RUN_ENV'] ||= 'prod'

CONFIG = Config.get_config

ENV['REL_LIVECORP_PATH'] = "#{CONFIG['rel_paths']['dropbox']}#{CONFIG['rel_paths']['livecorp']}"
bookkeeping_path = "#{CONFIG['rel_paths']['livecorp']}#{CONFIG['rel_paths']['bookkeeping']}"
ENV['CONTRACTS_FILEPATH'] = "#{ENV['TOOL_ROOT']}#{bookkeeping_path}#{CONFIG['filenames']['contracts']}"
ENV['SALES_AND_VAT_FILEPATH'] = "#{ENV['TOOL_ROOT']}#{bookkeeping_path}#{CONFIG['filenames']['sales_and_vat']}"
ENV['CONVERT_BANK_EXTRACT_SAVE_FILEPATH'] = "#{ENV['TOOL_ROOT']}#{CONFIG['rel_paths']['save_files']}#{CONFIG['filenames']['convert_bank_extract_save']}"
ENV['CONVERT_BANK_EXTRACT_SOURCE_FILEPATH'] = "#{ENV['TOOL_ROOT']}#{CONFIG['rel_paths']['source_files']}#{CONFIG['filenames']['convert_bank_extract_source']}"
