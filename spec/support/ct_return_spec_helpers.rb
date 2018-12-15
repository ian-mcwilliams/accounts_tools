require_relative '../../tax_management/summary_calculations'

module CtReturnSpecHelpers

  def self.verify_box_array(r, actual, expected)
    r.expect(actual).to r.be_a(Array)
    actual.each do |item|
      r.expect(item).to r.be_a(Hash)
      r.expect(item.keys).to r.eq(%i[box value])
    end
    r.expect(actual.map { |item| item[:box] }).to r.eq(expected.map { |item| item[:box] })
    expected.each { |item| r.expect(actual).to r.include(item) }
  end

  def self.input_accounts
    accounts_summary = {
      current: { accounts: balanced_accounts_summary },
      previous: { accounts: balanced_accounts_summary }
    }
    inputs = { current: TaxCheckerSpecHelpers.inputs_hash, previous: TaxCheckerSpecHelpers.inputs_hash }
    inputs[:previous]['PS12D'] = 2
    %i[current previous].each do |period|
      calculations = SummaryCalculations.report_calculations(period, accounts_summary[period][:accounts], inputs)
      accounts_summary[period][:accounts].concat(calculations)
    end
    accounts_summary
  end

  def self.reports_summary_inputs
    {
      'period' => 6,
      'S5B' => 566972,
      'PS12D' => 994366,
      'S22B' => 99900,
      'no_of_shares' => 1,
      'share_value' => 100
    }
  end

  def self.ct_profit_and_loss_hashes
    [
      { box: 'AC12', value: -20000 },
      { box: 'AC13', value: -20000 },
      { box: 'AC20', value: 130000 },
      { box: 'AC21', value: 130000 },
      { box: 'AC35', value: 1 },
      { box: 'AC38', value: 10000 },
      { box: 'AC39', value: 10000 }
    ]
  end

  def self.ct_balance_sheet_hashes
    [
      { box: 'AC52', value: 10000 },
      { box: 'AC53', value: 10000 },
      { box: 'AC54', value: 10000 },
      { box: 'AC55', value: 10000 },
      { box: 'AC58', value: -70001 },
      { box: 'AC59', value: -70001 },
      { box: 'AC64', value: 1 },
      { box: 'AC65', value: 1 },
      { box: 'AC67', value: 1 }
    ]
  end

  def self.ct_account_notes_hashes
    [
      { box: 'AC273', value: 1 },
      { box: 'AC274', value: 100 },
      { box: 'AC280', value: 1 },
      { box: 'AC281', value: 100 },
      { box: 'AC215', value: 10 }
    ]
  end

  def self.ct_computations_hashes
    [
      { box: 'CP7', value: -20000 },
      { box: 'CP17', value: 30000 },
      { box: 'CP22', value: 10000 },
      { box: 'CP23', value: 10000 },
      { box: 'CP27', value: 10000 },
      { box: 'CP34', value: 10000 },
      { box: 'CP36', value: 40000 },
      { box: 'CP37', value: 20000 }
    ]
  end

  def self.ct_section_hashes
    [
      { box: '1', value: -20000 }
    ]
  end

  def self.corporation_tax_return_hashes
    ct_profit_and_loss_hashes +
      ct_balance_sheet_hashes +
      ct_account_notes_hashes +
      ct_computations_hashes +
      ct_section_hashes
  end

  def self.balanced_accounts_summary
    [
      { account_code: 'A1', account_name: 'CASH', account_balance: :dr, dr: 15000, cr: 5000, balance: 10000 },
      { account_code: 'A2', account_name: 'AR', account_balance: :dr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'L1', account_name: 'VAT Payable', account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'L2', account_name: 'CT Payable', account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'L3', account_name: 'Salary Payable', account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'L4', account_name: 'PAYE Payable', account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'L5', account_name: 'Office Expenses Payable', account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'L6', account_name: 'Misc Expenses Payable', account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'L7', account_name: "Directors' Loans Payable", account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'E1', account_name: 'Capital', account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'E2', account_name: 'Withdrawal', account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'E3', account_name: 'CT', account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'E4', account_name: 'Net Sales', account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'E5', account_name: 'Retained VAT', account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'E6', account_name: 'Bank', account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'E7', account_name: 'Travel', account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'E8', account_name: 'Comms', account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'E9', account_name: 'Sundry', account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'E10', account_name: 'Salary', account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'E11', account_name: "Emp'ee tax & NI", account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'E12', account_name: "Emp'er NI", account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'E13', account_name: 'Fines', account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'E14', account_name: 'Co House', account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'E15', account_name: 'Office (Comms)', account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'E16', account_name: 'Office (Rent)', account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'E17', account_name: 'Office (Power)', account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'E18', account_name: 'Office (Sundry)', account_balance: :cr, dr: 12000, cr: 2000, balance: 10000 }
    ]
  end

end
