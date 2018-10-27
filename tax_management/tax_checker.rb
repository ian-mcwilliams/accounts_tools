require_relative '../file_tools'
require_relative 'accounts_ingress'
require_relative 'summary_calculations'
require 'json'

module TaxChecker
  include AccountsIngress
  include SummaryCalculations

  def self.reports_summary(period)
    accounts_summaries = AccountsIngress.accounts_summaries_ingress(period)
    accounts_summaries.each_with_object({}) do |(key, value), h|
      accounts_summary_validation(value)
      accounts_balances = accounts_balances_hash(value)
      accounts_balances_validation(key, accounts_balances)
      h[key] = {
        accounts_summary: value,
        balances: accounts_balances,
        calculations: SummaryCalculations.report_calculations(value)
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
    account_codes = account_code_arrays_by_balance(summary_array)
    assets_balance = specified_accounts_balance(account_codes[:assets], summary_array)
    liabilities_balance = specified_accounts_balance(account_codes[:liabilities], summary_array)
    equity_debit_balance = specified_accounts_balance(account_codes[:equity_debit], summary_array)
    equity_credit_balance = specified_accounts_balance(account_codes[:equity_credit], summary_array)
    {
      assets: 0 - assets_balance,
      liabilities: liabilities_balance,
      equity: equity_debit_balance - equity_credit_balance
    }
  end

  def self.account_code_arrays_by_balance(summary_array)
    all_account_codes = summary_array.map { |item| item[:account_code] }
    account_codes = {
      assets: all_account_codes.select { |item| item[/^A\d+.*$/] },
      liabilities: all_account_codes.select { |item| item[/^L\d+.*$/] }
    }
    equity_account_codes = all_account_codes.select { |item| item[/^E\d+.*$/] }
    account_codes[:equity_debit] = equity_account_codes.select do |account_code|
      summary_array.find { |item| item[:account_code] == account_code }[:account_balance] == :dr
    end
    account_codes[:equity_credit] = equity_account_codes.select do |account_code|
      summary_array.find { |item| item[:account_code] == account_code }[:account_balance] == :cr
    end
    account_codes
  end

  def self.specified_accounts_balance(specified_accounts, summary_array)
    assets_balances = summary_array.each_with_object([]) do |account_hash, a|
      a << account_hash[:balance] if specified_accounts.include?(account_hash[:account_code])
    end
    assets_balances.inject(0, :+)
  end

  def self.calculation_inputs
    JSON.parse(File.read('tax_management/calculation_inputs.json'))['calculation_inputs']
  end

end
