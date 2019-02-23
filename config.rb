require 'socket'
require 'yaml'

module Config
  def self.get_config
    raw_config = YAML.load_file('config.yml')
    params = raw_config['default']
    params['rel_paths']['dropbox'] = params['rel_paths']['dropbox'][host_key]
    params = merge_config(params, raw_config[ENV['RUN_ENV']])
    build_params(params)
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

  def self.build_params(params)
    filenames = params['filenames']
    rel_paths = params['rel_paths']
    tool_root = ENV['TOOL_ROOT']
    livecorp = "#{tool_root}#{rel_paths['dropbox']}#{rel_paths['livecorp']}"
    params['accounting_periods'] ||= (0..9).to_a.map { '' }
    params['accounting_period_filepaths'] = params['accounting_periods'].map.with_index(1) do |item, i|
      "#{livecorp}#{item}Accounts#{i}.xlsx"
    end
    params['bookkeeping_path'] = "#{livecorp}#{rel_paths['bookkeeping']}"
    params['bookkeeping_archive_path'] = "#{livecorp}#{rel_paths['bookkeeping']}#{rel_paths['archive']}"
    params['bank_book_filepath'] = "#{params['bookkeeping_path']}#{filenames['bank_book']}"
    params['bank_extract_filepath'] = "#{tool_root}#{rel_paths['source_files']}#{filenames['bank_extract']}"
    params['contracts_filepath'] = "#{params['bookkeeping_path']}#{filenames['contracts']}"
    params['invoices_filepath'] = "#{params['bookkeeping_path']}#{filenames['invoices']}"
    params['timesheets_filepath'] = "#{params['bookkeeping_path']}#{filenames['timesheets']}"
    params
  end
end