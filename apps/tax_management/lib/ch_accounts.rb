require_relative 'accounts_helpers'

module ChAccounts

  def self.abbreviated_accounts(summary)
    %i[current previous].each_with_object({}) do |period, h|
      h[period] = period_data(summary[period][:accounts])
    end
  end

  def self.period_data(accounts)
    {
      debtors: AccountsHelpers.account_balance(accounts, 'A2', :balance),
      cash_in_bank_and_at_hand: AccountsHelpers.account_balance(accounts, 'A1', :balance),
      creditors_within_one_year: AccountsHelpers.account_balance(accounts, '-S21', :balance),
      creditors_after_one_year: AccountsHelpers.account_balance(accounts, '-S22', :balance),
      called_up_share_capital: AccountsHelpers.account_balance(accounts, 'S7', :balance),
      profit_and_loss_account: AccountsHelpers.account_balance(accounts, 'S20', :balance)
    }
  end

  def self.abbreviated_accounts_validations(accounts)
    %i[current previous].each_with_object([]) do |period, a|
      unless accounts[period][:total_net_assets] == accounts[period][:shareholders_funds]
        a << [
          "total net assets (liabilities) [",
          currency_string(accounts[period][:total_net_assets]),
          "] different from shareholders' funds [",
          currency_string(accounts[period][:shareholders_funds]),
          '] for ',
          period,
          ' period'
        ].join
      end
    end
  end

  def self.currency_string(raw_value)
    string_value = raw_value.to_s
    2.times do
      break if string_value.length > 2
      string_value = "0#{string_value}"
    end
    "£#{string_value[0..-3]}.#{string_value[-2..-1]}"
  end

end