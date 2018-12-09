module ChAccountsSpecHelpers

  def self.abbreviated_accounts_input_accounts
    accounts = [
      { account_code: 'A1', account_name: 'CASH', account_balance: :dr, dr: 15000, cr: 5000, balance: 10000 },
      { account_code: 'A2', account_name: 'AR', account_balance: :dr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'S21', account_name: 'Creditors < 1 year', account_balance: :cr, dr: 3000, cr: 13000, balance: 10000 },
      { account_code: 'S22', account_name: 'Creditors > 1 year', account_balance: :cr, dr: 2000, cr: 12000, balance: 10000 },
      { account_code: 'S7', account_name: 'Share', account_balance: :cr, dr: 0, cr: 10000, balance: 10000 },
      { account_code: 'S20', account_name: 'Profit & Loss Acc', account_balance: :cr, dr: 500, cr: 10500, balance: 10000 }
    ]
    summary = { accounts: accounts, balances: nil }
    { current: summary, previous: summary }
  end

  def self.abbreviated_accounts_hash
    data = {
      debtors: 10000,
      cash_in_bank_and_at_hand: 10000,
      creditors_within_one_year: -10000,
      creditors_after_one_year: -10000,
      called_up_share_capital: 10000,
      profit_and_loss_account: 10000
    }
    { current: data, previous: data }
  end

  def self.ch_error_messages(values)
    message_values = [
      %w[£0.00 £0.01 current],
      %w[£0.01 £0.00 current],
      %w[£0.00 £0.01 previous],
      %w[£0.01 £0.00 previous],
    ]
    values.each_with_object([]) do |value, a|
      a << [
        'total net assets (liabilities) [',
        message_values[value][0],
        "] different from shareholders' funds [",
        message_values[value][1],
        '] for ',
        message_values[value][2],
        ' period'
      ].join
    end
  end

  def self.ch_verify_accounts_tests
    tests = [
      { inputs: [0, 0, 0, 0], expected: [] },
      { inputs: [1, 1, 1, 1], expected: [] },
      { inputs: [0, 1, 0, 0], expected: [0] },
      { inputs: [1, 0, 0, 0], expected: [1] },
      { inputs: [0, 0, 0, 1], expected: [2] },
      { inputs: [0, 0, 1, 0], expected: [3] },
      { inputs: [0, 1, 0, 1], expected: [0, 2] },
      { inputs: [1, 0, 1, 0], expected: [1, 3] },
      { inputs: [0, 1, 1, 0], expected: [0, 3] },
      { inputs: [1, 0, 0, 1], expected: [1, 2] }
    ]
    tests.each_with_object([]) do |test, a|
      a << {
        inputs: {
          current: { total_net_assets: test[:inputs][0], shareholders_funds: test[:inputs][1] },
          previous: { total_net_assets: test[:inputs][2], shareholders_funds: test[:inputs][3] }
        },
        expected: ch_error_messages(test[:expected])
      }
    end
  end

end