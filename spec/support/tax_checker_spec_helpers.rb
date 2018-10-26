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

  def self.test_expected_hash_array_a
    test_unbalanced_hash_array_generator(test_actual_account_array, 400000)
  end

  def self.test_expected_hash_array_b
    test_unbalanced_hash_array_generator(test_actual_account_array, 100000)
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