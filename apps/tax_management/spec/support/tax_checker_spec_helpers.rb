module TaxCheckerSpecHelpers

  def self.verify_accounts_array(r, actual, expected)
    r.expect(actual).to r.be_a(Array)
    r.expect(actual.map { |item| item[:account_code] }.sort).to r.eq(expected.map { |item| item[:account_code] }.sort)
    expected.each do |account|
      r.expect(actual.select { |item| item[:account_code] == account[:account_code] }[0]).to r.eq(account)
    end
  end

  def self.verify_reports_summary(r, actual, expected)
    %i[current previous].each do |period|
      r.expect(actual[period]).to r.be_a(Hash)
      r.expect(actual[period].keys.sort).to r.eq(expected[period].keys.sort)
      r.expect(actual[period][:accounts]).to r.be_a(Array)
      verify_accounts_array(r, actual[period][:accounts], expected[period][:accounts])
      r.expect(actual[period][:balances]).to r.eq(expected[period][:balances])
    end
  end

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

  def self.inputs_hash(zero = false)
    keys = %w[S5B PS12D S22B]
    value = zero ? 0 : 1
    inputs = keys.each_with_object({}) { |key, h| h[key] = value }
    inputs.merge('no_of_shares' => value, 'share_value' => value)
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

  def self.initial_calculation_non_zero_array
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
      { account_code: 'S7', account_name: 'Share Capital', balance_type: :cr, dr: 0, cr: 0, balance: 0 },
      { account_code: 'S22', account_name: 'Creditors > 1 year', balance_type: :cr, dr: 0, cr: 0, balance: 0 }
    ]
    ct_account = { account_code: 'S12', account_name: 'CT Payable', balance_type: :dr, dr: 0, cr: 0, balance: 0 }
    { current: accounts, previous: accounts + [ct_account] }[period]
  end

  def self.input_calculation_non_zero_array(period)
    accounts = [
      { account_code: 'S5', account_name: 'B/F Capital', balance_type: :cr, dr: 0, cr: 1, balance: 1 },
      { account_code: 'S7', account_name: 'Share Capital', balance_type: :cr, dr: 0, cr: 1, balance: 1 },
      { account_code: 'S22', account_name: 'Creditors > 1 year', balance_type: :cr, dr: 0, cr: 1, balance: 1 }
    ]
    ct_account = { account_code: 'S12', account_name: 'CT Payable', balance_type: :dr, dr: 1, cr: 0, balance: 1 }
    { current: accounts, previous: accounts + [ct_account] }[period]
  end

  def self.composite_calculation_zero_array
    [
      { account_code: 'S11', account_name: 'Profit before tax', balance_type: :cr, dr: 0, cr: 0, balance: 0 },
      { account_code: 'S13', account_name: 'Profit after tax', balance_type: :cr, dr: 0, cr: 0, balance: 0 },
      { account_code: 'S14', account_name: 'Final Capital', balance_type: :cr, dr: 0, cr: 0, balance: 0 },
      { account_code: 'S18', account_name: 'Total Salary Exp', balance_type: :dr, dr: 0, cr: 0, balance: 0 },
      { account_code: 'S20', account_name: 'Profit and Loss Acc', balance_type: :cr, dr: 0, cr: 0, balance: 0 },
      { account_code: 'S21', account_name: 'Creditors < 1 year', balance_type: :cr, dr: 0, cr: 0, balance: 0 },
      { account_code: 'S23', account_name: 'Opening Balance', balance_type: :cr, dr: 0, cr: 0, balance: 0 },
      { account_code: 'S24', account_name: 'CH P&L Account', balance_type: :cr, dr: 0, cr: 0, balance: 0 }
    ]
  end

  def self.composite_calculation_non_zero_array(period)
    profit_after_tax_balances = {
      current: { dr: 13, cr: 2, balance: -11 },
      previous: { dr: 14, cr: 2, balance: -12 }
    }[period]
    profit_and_loss_acc_balances = {
      current: { dr: 12, cr: 2, balance: -10 },
      previous: { dr: 11, cr: 2, balance: -9 }
    }[period]
    [
      { account_code: 'S11', account_name: 'Profit before tax', balance_type: :cr, dr: 13, cr: 2, balance: -11 },
      { account_code: 'S13', account_name: 'Profit after tax', balance_type: :cr }.merge(profit_after_tax_balances),
      { account_code: 'S14', account_name: 'Final Capital', balance_type: :cr, dr: 12, cr: 3, balance: -9 },
      { account_code: 'S18', account_name: 'Total Salary Exp', balance_type: :dr, dr: 3, cr: 0, balance: 3 },
      { account_code: 'S20', account_name: 'Profit and Loss Acc', balance_type: :cr }.merge(profit_and_loss_acc_balances),
      { account_code: 'S21', account_name: 'Creditors < 1 year', balance_type: :cr, dr: 0, cr: 13, balance: 13 },
      { account_code: 'S23', account_name: 'Opening Balance', balance_type: :cr, dr: 0, cr: 0, balance: 0 },
      { account_code: 'S24', account_name: 'CH P&L Account', balance_type: :cr, dr: 12, cr: 2, balance: -10 }
    ]
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

  def self.abbreviated_accounts_hash
    {
      current: {
        debtors: 1,
        cash_in_bank_and_at_hand: 1,
        creditors_within_one_year: -13,
        creditors_after_one_year: -1,
        called_up_share_capital: 1,
        profit_and_loss_account: -10
      },
      previous: {
        debtors: 1,
        cash_in_bank_and_at_hand: 1,
        creditors_within_one_year: -13,
        creditors_after_one_year: -1,
        called_up_share_capital: 1,
        profit_and_loss_account: -9
      }
    }
  end

  def self.ct_return_inputs_array
    [
      { box: 'AC12', value: 2 },
      { box: 'AC13', value: 2 },
      { box: 'AC20', value: 13 },
      { box: 'AC21', value: 13 },
      { box: 'AC35', value: 1 },
      { box: 'AC38', value: 1 },
      { box: 'AC39', value: 1 },
      { box: 'AC52', value: 1 },
      { box: 'AC53', value: 1 },
      { box: 'AC54', value: 1 },
      { box: 'AC55', value: 1 },
      { box: 'AC58', value: 13 },
      { box: 'AC59', value: 13 },
      { box: 'AC64', value: 1 },
      { box: 'AC65', value: 1 },
      { box: 'AC67', value: 1 },
      { box: 'AC273', value: 1 },
      { box: 'AC274', value: 1 },
      { box: 'AC280', value: 1 },
      { box: 'AC281', value: 1 },
      { box: 'AC215', value: 0 },
      { box: 'CP7', value: 2 },
      { box: 'CP17', value: 3 },
      { box: 'CP22', value: 1 },
      { box: 'CP23', value: 1 },
      { box: 'CP27', value: 1 },
      { box: 'CP34', value: 1 },
      { box: 'CP36', value: 4 },
      { box: 'CP37', value: 2 },
      { box: '1', value: 2 }
    ]
  end

end