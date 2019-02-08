require 'simple_xlsx_reader'
require_relative '../../config'

module AccountsIngress
  CONFIG = Config.get_config

  def self.accounts_summaries_ingress(period)
    unless period.is_a?(Integer) && period > 0
      raise('period must be an integer greater than 0')
    end
    accounts_summaries = {
      current: accounts_summary_array(period),
      previous: nil
    }
    if period > 1
      accounts_summaries[:previous] = accounts_summary_array(period - 1)
    end
    accounts_summaries
  end

  def self.accounts_summary_rows(period)
    file = SimpleXlsxReader.open(CONFIG['accounting_period_filepaths'][period].to_s)
    file.sheets.each do |sheet|
      return sheet.rows if sheet.name == 'Accounts Summary'
    end
  end

  def self.accounts_summary_array(period)
    rows = accounts_summary_rows(period)
    (1..27).each_with_object([]) do |i, a|
      account_code = rows[i][1][/^\D\d+/]
      account_name = rows[i][1].gsub("#{account_code}. ", '')
      a << {
        account_code: account_code,
        account_name: account_name,
        account_balance: { debit: :dr, credit: :cr }[rows[i][2].downcase.to_sym],
        dr: (rows[i][3] * 100).round.to_i,
        cr: (rows[i][4] * 100).round.to_i,
        balance: (rows[i][5] * 100).round.to_i
      }
    end
  end

end