module TaxCheckerSpecHelpers

  def self.test_unbalanced_hash_array_generator(inputs, start_val)
    dr, cr, balance = [start_val, start_val + 100000, start_val + 200000]
    inputs.each_with_object([]) do |input, a|
      a << {
        account_code: input[:account_code],
        account_name: input[:account_name],
        account_balance: input[:account_balance],
        dr: dr,
        cr: cr,
        balance: balance
      }
      dr += 100
      cr += 100
      balance += 100
    end
  end

  def self.unbalanced_actual_account_array(start_val)
    test_unbalanced_hash_array_generator(test_actual_account_array, start_val)
  end

  def self.zero_actual_account_array
    initial_array = test_unbalanced_hash_array_generator(test_actual_account_array, 0)
    initial_array.each do |account|
      account[:dr] = 0
      account[:cr] = 0
      account[:balance] = 0
    end
  end

  def self.non_zero_account_array
    initial_array = test_unbalanced_hash_array_generator(test_actual_account_array, 0)
    initial_array.each do |account|
      account.merge!(non_zero_balancing_account_values(account[:account_code], account[:account_balance]))
    end
  end

  def self.non_zero_balancing_account_values(code, balance_type)
    return { dr: 1, cr: 0, balance: 1 } if balance_type == :dr
    return { dr: 0, cr: 2, balance: 2 } if code[/^L\d$/]
    { dr: 0, cr: 1, balance: 1 }
  end

  def self.initial_calculation_zero_array
    [
      { account_code: 'S1', account_name: 'Total Comms Exp', balance_type: :dr, dr: 0, cr: 0, balance: 0 },
      { account_code: 'S2', account_name: 'Total Sundry Exp', balance_type: :dr, dr: 0, cr: 0, balance: 0 },
      { account_code: 'S3', account_name: 'Total PAYE Exp', balance_type: :dr, dr: 0, cr: 0, balance: 0 },
      { account_code: 'S4', account_name: 'A/P excl VAT', balance_type: :cr, dr: 0, cr: 0, balance: 0 },
      { account_code: 'S9', account_name: 'Total Revenue', balance_type: :cr, dr: 0, cr: 0, balance: 0 },
      { account_code: 'S10', account_name: 'Total Expenses', balance_type: :dr, dr: 0, cr: 0, balance: 0 },
      { account_code: 'S17', account_name: 'Total Liabilities', balance_type: :cr, dr: 0, cr: 0, balance: 0 },
      { account_code: 'S19', account_name: 'Admin & Office Exp', balance_type: :dr, dr: 0, cr: 0, balance: 0 }
    ]
  end

  def self.expected_initial_non_zero_calculations
    [
      { account_code: 'S1', account_name: 'Total Comms Exp', balance_type: :dr, dr: 2, cr: 0, balance: 2 },
      { account_code: 'S2', account_name: 'Total Sundry Exp', balance_type: :dr, dr: 2, cr: 0, balance: 2 },
      { account_code: 'S3', account_name: 'Total PAYE Exp', balance_type: :dr, dr: 2, cr: 0, balance: 2 },
      { account_code: 'S4', account_name: 'A/P excl VAT', balance_type: :cr, dr: 0, cr: 10, balance: 10 },
      { account_code: 'S9', account_name: 'Total Revenue', balance_type: :cr, dr: 0, cr: 2, balance: 2 },
      { account_code: 'S10', account_name: 'Total Expenses', balance_type: :dr, dr: 13, cr: 0, balance: 13 },
      { account_code: 'S17', account_name: 'Total Liabilities', balance_type: :cr, dr: 0, cr: 14, balance: 14 },
      { account_code: 'S19', account_name: 'Admin & Office Exp', balance_type: :dr, dr: 4, cr: 0, balance: 4 }
    ]
  end

  def self.input_calculation_zero_array(period)
    accounts = [
      { account_code: 'S5', account_name: 'B/F Capital', balance_type: :cr, dr: 0, cr: 0, balance: 0 },
      { account_code: 'S22', account_name: 'Creditors > 1 year', balance_type: :cr, dr: 0, cr: 0, balance: 0 }
    ]
    ct_account = { account_code: 'S12', account_name: 'CT Payable', balance_type: :dr, dr: 0, cr: 0, balance: 0 }
    { current: accounts, previous: accounts + [ct_account] }[period]
  end

  def self.input_calculation_non_zero_array(period)
    accounts = [
      { account_code: 'S5', account_name: 'B/F Capital', balance_type: :cr, dr: 0, cr: 1, balance: 1 },
      { account_code: 'S22', account_name: 'Creditors > 1 year', balance_type: :cr, dr: 0, cr: 1, balance: 1 }
    ]
    ct_account = { account_code: 'S12', account_name: 'CT Payable', balance_type: :dr, dr: 1, cr: 0, balance: 1 }
    { current: accounts, previous: accounts + [ct_account] }[period]
  end

  def self.test_actual_account_array
    [
      { account_code: 'A1', account_name: 'CASH', account_balance: :dr },
      { account_code: 'A2', account_name: 'AR', account_balance: :dr },
      { account_code: 'L1', account_name: 'VAT Payable', account_balance: :cr },
      { account_code: 'L2', account_name: 'CT Payable', account_balance: :cr },
      { account_code: 'L3', account_name: 'Salary Payable', account_balance: :cr },
      { account_code: 'L4', account_name: 'PAYE Payable', account_balance: :cr },
      { account_code: 'L5', account_name: 'Office Expenses Payable', account_balance: :cr },
      { account_code: 'L6', account_name: 'Misc Expenses Payable', account_balance: :cr },
      { account_code: 'L7', account_name: "Directors' Loans Payable", account_balance: :cr },
      { account_code: 'E1', account_name: 'Capital', account_balance: :cr },
      { account_code: 'E2', account_name: 'Withdrawal', account_balance: :dr },
      { account_code: 'E3', account_name: 'CT', account_balance: :dr },
      { account_code: 'E4', account_name: 'Net Sales', account_balance: :cr },
      { account_code: 'E5', account_name: 'Retained VAT', account_balance: :cr },
      { account_code: 'E6', account_name: 'Bank', account_balance: :dr },
      { account_code: 'E7', account_name: 'Travel', account_balance: :dr },
      { account_code: 'E8', account_name: 'Comms', account_balance: :dr },
      { account_code: 'E9', account_name: 'Sundry', account_balance: :dr },
      { account_code: 'E10', account_name: 'Salary', account_balance: :dr },
      { account_code: 'E11', account_name: "Emp'ee tax & NI", account_balance: :dr },
      { account_code: 'E12', account_name: "Emp'er NI", account_balance: :dr },
      { account_code: 'E13', account_name: 'Fines', account_balance: :dr },
      { account_code: 'E14', account_name: 'Co House', account_balance: :dr },
      { account_code: 'E15', account_name: 'Office (Comms)', account_balance: :dr },
      { account_code: 'E16', account_name: 'Office (Rent)', account_balance: :dr },
      { account_code: 'E17', account_name: 'Office (Power)', account_balance: :dr },
      { account_code: 'E18', account_name: 'Office (Sundry)', account_balance: :dr }
    ]
  end

  def self.test_simple_unbalanced_hash_array
    [
      { account_code: 'A1', account_name: 'test_asset_account', account_balance: :dr, dr: 200, cr: 50,
        balance: 150 },
      { account_code: 'L1', account_name: 'test_liability_account', account_balance: :cr, dr: 50, cr: 300,
        balance: 250 },
      { account_code: 'E1', account_name: 'test_equity_debit_account', account_balance: :dr, dr: 20, cr: 400,
        balance: 380 },
      { account_code: 'E2', account_name: 'test_equity_credit_account', account_balance: :cr, dr: 60, cr: 500,
        balance: 440 }
    ]
  end

end