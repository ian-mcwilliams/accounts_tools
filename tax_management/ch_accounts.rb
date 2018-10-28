require_relative 'accounts_helpers'

module ChAccounts
  include AccountsHelpers

  def self.abbreviated_accounts(accounts)
    %i[current previous].each_with_object({}) do |period, h|
      h[period] = period_data(accounts[period])
    end
  end

  def self.period_data(accounts)
    {
      debtors: AccountsHelpers.account_balance(accounts[:accounts], 'A2', :balance),
      cash_in_bank_and_at_hand: AccountsHelpers.account_balance(accounts[:accounts], 'A1', :balance),
      creditors_within_one_year: AccountsHelpers.account_balance(accounts[:calculations], '-S21', :balance),
      creditors_after_one_year: AccountsHelpers.account_balance(accounts[:calculations], '-S22', :balance),
      called_up_share_capital: AccountsHelpers.account_balance(accounts[:calculations], 'S7', :balance),
      profit_and_loss_account: AccountsHelpers.account_balance(accounts[:calculations], 'S20', :balance)
    }
  end

  def self.verify_accounts(accounts)
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