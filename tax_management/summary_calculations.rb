module SummaryCalculations

  def self.report_calculations(period, summary, inputs)
    accounts = initial_calculations(summary)
    accounts.concat(input_calculations(period, inputs))
    accounts.concat(composite_calculations(period, summary + accounts))
    accounts
  end

  def self.accounts_spec_to_accounts(accounts, spec)
    spec.each_with_object([]) do |account, a|
      current_calculation = calculation(accounts, account[:accounts], account[:balance_type])
      current_hash = {
        account_code: account[:code],
        account_name: account[:name],
        balance_type: account[:balance_type]
      }
      a << current_hash.merge(current_calculation)
    end
  end

  def self.initial_calculations(summary)
    accounts_spec_to_accounts(summary, initial_calculation_data)
  end

  def self.input_calculations(period, inputs)
    accounts = [
      { account_code: 'S5', account_name: 'B/F Capital', balance_type: :cr, dr: 0, cr: inputs['S5C'],
        balance: inputs['S5C'] },
      { account_code: 'S7', account_name: 'Share Capital', balance_type: :cr, dr: 0, cr: inputs['S7C'],
        balance: inputs['S5C'] },
      { account_code: 'S22', account_name: 'Creditors > 1 year', balance_type: :cr, dr: 0, cr: inputs['S22C'],
        balance: inputs['S22C'] }
    ]
    if period == :previous
      ct_account = { account_code: 'S12', account_name: 'CT Payable', balance_type: :dr, dr: inputs['S12D'], cr: 0,
                     balance: inputs['S12D'] }
      accounts.concat([ct_account])
    end
    accounts
  end

  def self.composite_calculations(period, accounts)
    profit_after_tax_accounts = { current: %w[S9 S10], previous: %w[S9 S10 S12] }[period]
    profit_and_loss_accounts = { current: %w[S5 S11 -E2 -S7], previous: %w[S5 S11 -E2 -S7 -S12] }[period]
    composite_accounts_spec = [
      { code: 'S11', name: 'Profit before tax', balance_type: :cr, accounts: %w[S9 S10] },
      { code: 'S13', name: 'Profit after tax', balance_type: :cr, accounts: profit_after_tax_accounts },
      { code: 'S14', name: 'Final Capital', balance_type: :cr, accounts: %w[S5 S11 -E2] },
      { code: 'S18', name: 'Total Salary Exp', balance_type: :dr, accounts: %w[E10 S3] },
      { code: 'S20', name: 'Profit and Loss Acc', balance_type: :cr, accounts: profit_and_loss_accounts },
      { code: 'S21', name: 'Creditors < 1 year', balance_type: :cr, accounts: %w[S17 -S22] },
      { code: 'S23', name: 'Opening Balance', balance_type: :cr, accounts: %w[S5 -S7] },
      { code: 'S24', name: 'CH P&L Account', balance_type: :cr, accounts: %w[S5 S11 -E2 -S7] }
    ]
    composite_accounts = []
    composite_accounts_spec.each do |spec|
      composite_accounts.concat(accounts_spec_to_accounts(accounts + composite_accounts, [spec]))
    end
    composite_accounts
  end

  def self.calculation(summary, accounts, balance_type)
    dr_cr = accounts.each_with_object({ dr: 0, cr: 0 }) do |account, h|
      h[:dr] += account_balance(summary, account, :dr)
      h[:cr] += account_balance(summary, account, :cr)
    end
    balance = {
      dr: dr_cr[:dr] - dr_cr[:cr],
      cr: dr_cr[:cr] - dr_cr[:dr]
    }[balance_type]
    dr_cr.merge(balance: balance)
  end

  def self.account_balance(summary, account, key)
    account_hash = summary.find { |item| item[:account_code] == account.gsub('-', '') }
    raise("no account found for #{account}") unless account_hash
    account[0] == '-' ? account_hash[key] - (account_hash[key] * 2) : account_hash[key]
  end

  def self.initial_calculation_data
    [
      { code: 'S1', name: 'Total Comms Exp', accounts: %w[E8 E15], balance_type: :dr },
      { code: 'S2', name: 'Total Sundry Exp', accounts: %w[E9 E18], balance_type: :dr },
      { code: 'S3', name: 'Total PAYE Exp', accounts: %w[E11 E12], balance_type: :dr },
      { code: 'S4', name: 'A/P excl VAT', accounts: ('L2'..'L6').to_a, balance_type: :cr },
      { code: 'S9', name: 'Total Revenue', accounts: %w[E4 E5], balance_type: :cr },
      { code: 'S10', name: 'Total Expenses', accounts: (6..18).map { |num| "E#{num}" }, balance_type: :dr },
      { code: 'S17', name: 'Total Liabilities', accounts: ('L1'..'L7').to_a, balance_type: :cr },
      { code: 'S19', name: 'Admin & Office Exp', accounts: ['E8'] + ('E13'..'E15').to_a, balance_type: :dr }
    ]
  end

end