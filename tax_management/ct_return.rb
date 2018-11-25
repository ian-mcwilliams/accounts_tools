require_relative 'accounts_helpers'

class CtReturn

  def self.ct_profit_and_loss(summary)
    [
      { box: 'AC12', value: AccountsHelpers.account_balance(summary[:current], 'S9', :balance) },
      { box: 'AC13', value: AccountsHelpers.account_balance(summary[:previous], 'S9', :balance) },
      { box: 'AC20', value: AccountsHelpers.account_balance(summary[:current], 'S10', :balance) },
      { box: 'AC21', value: AccountsHelpers.account_balance(summary[:previous], 'S10', :balance) },
      { box: 'AC35', value: AccountsHelpers.account_balance(summary[:previous], 'S12', :balance) },
      { box: 'AC38', value: AccountsHelpers.account_balance(summary[:current], 'E2', :balance) },
      { box: 'AC39', value: AccountsHelpers.account_balance(summary[:previous], 'E2', :balance) }
    ]
  end

end