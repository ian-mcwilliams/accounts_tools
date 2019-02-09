require 'rxl'
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
    file = Rxl.read_file(CONFIG['accounting_period_filepaths'][period - 1].to_s)
    file['Accounts Summary']
  end

  def self.accounts_summary_array(period)
    cells = accounts_summary_rows(period)
    (2..28).each_with_object([]) do |i, a|
      account_code = cells["B#{i}"][:value][/^\D\d+/]
      account_name = cells["B#{i}"][:value].gsub("#{account_code}. ", '')
      a << {
        account_code: account_code,
        account_name: account_name,
        account_balance: { debit: :dr, credit: :cr }[cells["C#{i}"][:value].downcase.to_sym],
        dr: (cells["D#{i}"][:value] * 100).round.to_i,
        cr: (cells["E#{i}"][:value] * 100).round.to_i,
        balance: (cells["F#{i}"][:value] * 100).round.to_i
      }
    end
  end

end