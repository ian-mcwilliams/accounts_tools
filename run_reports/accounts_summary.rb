require_relative '../file_tools'
require 'socket'
require_relative 'account'

class AccountsSummary

  attr_accessor(:accounting_period, :accounts, :assets_value, :liabilities_plus_equity_value, :accounts_balance)

  def initialize(accounting_period)
    @accounting_period = accounting_period
    @accounts = get_accounts
    @assets_value = get_assets_value.round(2)
    @liabilities_plus_equity_value = get_liabilities_plus_equity_value.round(2)
    @accounts_balance = @assets_value + @liabilities_plus_equity_value.round(2)
  end

  def get_accounts
    summaries = []
    accounts = FileTools.new(8, :accounts, :accounts)
    accounts.contents.sheets.each do |sheet|
      if sheet.name == 'Accounts Summary'
        sheet.rows.each do |row|
          if row[1] && row[1][0] != 'B'
            code, name = row[1].split('. ')
            summaries << Account.new({
                                   code: code,
                                   name: name,
                                   balance: row[2].gsub('Debit', 'dr').gsub('Credit', 'cr').to_sym,
                                   dr_value: row[3].round(2),
                                   cr_value: row[4].round(2)
                               })
          end
        end
      end
    end
    summaries
  end

  def get_assets_value
    assets_value = 0.00
    @accounts.each { |account| assets_value += account.adj_value if account.code[0] == 'A' }
    assets_value
  end

  def get_liabilities_plus_equity_value
    liabilities_plus_equity_value = 0.00
    @accounts.each { |account| liabilities_plus_equity_value += account.adj_value if account.code[0] != 'A' }
    liabilities_plus_equity_value
  end


end