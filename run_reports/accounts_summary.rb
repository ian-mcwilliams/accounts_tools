require_relative '../file_tools'
require 'socket'

class AccountsSummary

    def initialize(accounting_period)
      @accounting_period = accounting_period
      @accounts = get_accounts

    end

  def get_accounts
    accounts = FileTools.new(8, :accounts, :accounts)
    accounts.contents.sheets.each do |sheet|
      if sheet.name == 'Accounts Summary'
        valid_rows = []
        sheet.rows.each do |row|
          valid_rows << row if row[1]
        end
        @rows = valid_rows
        return get_accounts_hash
      end
    end

  end

  def get_accounts_hash
    @rows.each do |row|
      accounts[row]
    end
  end


end