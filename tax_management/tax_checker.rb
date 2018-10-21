require_relative '../file_tools'
require_relative 'reports_summary_calculations'
require 'json'

module TaxChecker
  include ReportsSummaryCalculations

  def self.reports_summary(period)
    accounts_summaries = accounts_summaries_ingress(period)
    accounts_summaries.each_with_object({}) do |(key, value), h|
      accounts_summary_validation(value)
      accounts_balances = accounts_balances_hash(value)
      accounts_balances_validation(key, accounts_balances)
      h[key] = {
        accounts_summary: value,
        balances: accounts_balances,
        calculations: ReportsSummaryCalculations.report_calculations(key, value)
      }
    end
  end

  def self.accounts_summaries_ingress(period)
    unless period.is_a?(Integer) && period > 0
      raise('period must be an integer greater than 0')
    end
    accounts_summaries = {
      current_period: accounts_summary_array(period),
      previous_period: nil
    }
    if period > 1
      accounts_summaries[:previous_period] = accounts_summary_array(period - 1)
    end
    accounts_summaries
  end

  def self.accounts_summary_rows(period)
    file = SimpleXlsxReader.open(accounts_file_path(period))
    file.sheets.each do |sheet|
      return sheet.rows if sheet.name == 'Accounts Summary'
    end
  end

  def self.accounts_file_path(period)
    rel_dropbox_path = '../../Dropbox/'
    livecorp_path = 'F3Mmedia/Internal/ACcounts/LiveCorp/'
    accounts_file_path = "#{period}.#{period_strings[period - 1]}/Accounts#{period}.xlsx"
    "#{rel_dropbox_path}#{livecorp_path}#{accounts_file_path}"
  end

  def self.period_strings
    %w[
      1009-1108
      1109-1110
      1111-1210
      1211-1310
      1311-1410
      1411-1510
      1511-1610
      1611-1710
      1711-1810
    ]
  end

  def self.accounts_summary_array(period)
    rows = accounts_summary_rows(period)
    (1..27).each_with_object([]) do |i, a|
      account_code = rows[i][1][/^\D\d+/]
      account_name = rows[i][1].delete("#{account_code}. ")
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

  def self.accounts_summary_validation(summary_array)
    summary_array.each do |account_hash|
      calculation = {
        dr: account_hash[:dr] - account_hash[:cr],
        cr: account_hash[:cr] - account_hash[:dr]
      }[account_hash[:account_balance]]
      unless calculation == account_hash[:balance]
        raise("summary validation failed for account '#{account_hash[:account_name]}'")
      end
    end
  end

  def self.accounts_balances_validation(period, accounts_balances)
    assets_less_liabilities = accounts_balances[:assets] + accounts_balances[:liabilities]
    unless assets_less_liabilities == accounts_balances[:equity]
      raise("assets less liabilities (#{assets_less_liabilities}) is not equal to equity (#{accounts_balances[:equity]}) for #{period}")
    end
  end

  def self.accounts_balances_hash(summary_array)
    account_names = account_name_arrays_by_balance(summary_array)
    assets_balance = specified_accounts_balance(account_names[:assets], summary_array)
    liabilities_balance = specified_accounts_balance(account_names[:liabilities], summary_array)
    equity_debit_balance = specified_accounts_balance(account_names[:equity_debit], summary_array)
    equity_credit_balance = specified_accounts_balance(account_names[:equity_credit], summary_array)
    {
      assets: 0 - assets_balance,
      liabilities: liabilities_balance,
      equity: equity_debit_balance - equity_credit_balance
    }
  end

  def self.account_name_arrays_by_balance(summary_array)
    all_account_names = summary_array.map { |item| item[:account_name] }
    account_names = {
      assets: all_account_names.select { |item| item[/^A\d+.*$/] },
      liabilities: all_account_names.select { |item| item[/^L\d+.*$/] }
    }
    equity_account_names = all_account_names.select { |item| item[/^E\d+.*$/] }
    account_names[:equity_debit] = equity_account_names.select do |account_name|
      summary_array.find { |item| item[:account_name] == account_name }[:account_balance] == :dr
    end
    account_names[:equity_credit] = equity_account_names.select do |account_name|
      summary_array.find { |item| item[:account_name] == account_name }[:account_balance] == :cr
    end
    account_names
  end

  def self.specified_accounts_balance(specified_accounts, summary_array)
    assets_balances = summary_array.each_with_object([]) do |account_hash, a|
      a << account_hash[:balance] if specified_accounts.include?(account_hash[:account_name])
    end
    assets_balances.inject(0, :+)
  end

end
