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

  def self.ct_balance_sheet_inputs(summary)
    [
      { box: 'AC52', value: AccountsHelpers.account_balance(summary[:current], 'A2', :balance) },
      { box: 'AC53', value: AccountsHelpers.account_balance(summary[:previous], 'A2', :balance) },
      { box: 'AC54', value: AccountsHelpers.account_balance(summary[:current], 'A1', :balance) },
      { box: 'AC55', value: AccountsHelpers.account_balance(summary[:previous], 'A1', :balance) },
      { box: 'AC58', value: AccountsHelpers.account_balance(summary[:current], 'S21', :balance) },
      { box: 'AC59', value: AccountsHelpers.account_balance(summary[:previous], 'S21', :balance) },
      { box: 'AC64', value: AccountsHelpers.account_balance(summary[:current], 'S22', :balance) },
      { box: 'AC65', value: AccountsHelpers.account_balance(summary[:previous], 'S22', :balance) },
      { box: 'AC67', value: AccountsHelpers.account_balance(summary[:previous], 'S12', :balance) }
    ]
  end

  def self.ct_account_notes_inputs(summary, current_period_inputs, previous_period_inputs)
    [
      { box: 'AC273', value: previous_period_inputs['no_of_shares'] },
      { box: 'AC274', value: previous_period_inputs['share_value'] },
      { box: 'AC280', value: current_period_inputs['no_of_shares'] },
      { box: 'AC281', value: current_period_inputs['share_value'] },
      { box: 'AC215', value: AccountsHelpers.account_balance(summary[:current], 'S23', :balance) }
    ]
  end

end