require_relative 'accounts_helpers'

class CtReturn

  def self.ct_profit_and_loss(summary)
    [
      { box: 'AC12', value: AccountsHelpers.account_balance(summary[:current][:accounts], 'S9', :balance) },
      { box: 'AC13', value: AccountsHelpers.account_balance(summary[:previous][:accounts], 'S9', :balance) },
      { box: 'AC20', value: AccountsHelpers.account_balance(summary[:current][:accounts], 'S10', :balance) },
      { box: 'AC21', value: AccountsHelpers.account_balance(summary[:previous][:accounts], 'S10', :balance) },
      { box: 'AC35', value: AccountsHelpers.account_balance(summary[:previous][:accounts], 'S12', :balance) },
      { box: 'AC38', value: AccountsHelpers.account_balance(summary[:current][:accounts], 'E2', :balance) },
      { box: 'AC39', value: AccountsHelpers.account_balance(summary[:previous][:accounts], 'E2', :balance) }
    ]
  end

  def self.ct_balance_sheet_inputs(summary)
    [
      { box: 'AC52', value: AccountsHelpers.account_balance(summary[:current][:accounts], 'A2', :balance) },
      { box: 'AC53', value: AccountsHelpers.account_balance(summary[:previous][:accounts], 'A2', :balance) },
      { box: 'AC54', value: AccountsHelpers.account_balance(summary[:current][:accounts], 'A1', :balance) },
      { box: 'AC55', value: AccountsHelpers.account_balance(summary[:previous][:accounts], 'A1', :balance) },
      { box: 'AC58', value: AccountsHelpers.account_balance(summary[:current][:accounts], 'S21', :balance) },
      { box: 'AC59', value: AccountsHelpers.account_balance(summary[:previous][:accounts], 'S21', :balance) },
      { box: 'AC64', value: AccountsHelpers.account_balance(summary[:current][:accounts], 'S22', :balance) },
      { box: 'AC65', value: AccountsHelpers.account_balance(summary[:previous][:accounts], 'S22', :balance) },
      { box: 'AC67', value: AccountsHelpers.account_balance(summary[:previous][:accounts], 'S12', :balance) }
    ]
  end

  def self.ct_account_notes_inputs(summary, current_period_inputs, previous_period_inputs)
    [
      { box: 'AC273', value: previous_period_inputs['no_of_shares'] },
      { box: 'AC274', value: previous_period_inputs['share_value'] },
      { box: 'AC280', value: current_period_inputs['no_of_shares'] },
      { box: 'AC281', value: current_period_inputs['share_value'] },
      { box: 'AC215', value: AccountsHelpers.account_balance(summary[:previous][:accounts], 'S23', :balance) }
    ]
  end

  def self.ct_computations_inputs(summary)
    [
      { box: 'CP7', value: AccountsHelpers.account_balance(summary[:current][:accounts], 'S9', :balance) },
      { box: 'CP17', value: AccountsHelpers.account_balance(summary[:current][:accounts], 'S18', :balance) },
      { box: 'CP22', value: AccountsHelpers.account_balance(summary[:current][:accounts], 'E17', :balance) },
      { box: 'CP23', value: AccountsHelpers.account_balance(summary[:current][:accounts], 'E16', :balance) },
      { box: 'CP27', value: AccountsHelpers.account_balance(summary[:current][:accounts], 'E6', :balance) },
      { box: 'CP34', value: AccountsHelpers.account_balance(summary[:current][:accounts], 'E7', :balance) },
      { box: 'CP36', value: AccountsHelpers.account_balance(summary[:current][:accounts], 'S19', :balance) },
      { box: 'CP37', value: AccountsHelpers.account_balance(summary[:current][:accounts], 'S2', :balance) },
    ]
  end

  def self.ct_section_inputs(summary)
    [
      { box: '1', value: AccountsHelpers.account_balance(summary[:current][:accounts], 'S9', :balance) }
    ]
  end

  def self.corporation_tax_return_inputs(summary, current_period_inputs, previous_period_inputs)
    ct_profit_and_loss(summary) +
      ct_balance_sheet_inputs(summary) +
      ct_account_notes_inputs(summary, current_period_inputs, previous_period_inputs) +
      ct_computations_inputs(summary) +
      ct_section_inputs(summary)
  end

end