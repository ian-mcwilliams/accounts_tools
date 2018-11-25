require_relative '../../tax_management/summary_calculations'

module CtReturnSpecHelpers

  def self.input_accounts
    accounts_summary = { current: [] + balanced_accounts_summary, previous: [] + balanced_accounts_summary }
    %i[current previous].each do |period|
      inputs = TaxCheckerSpecHelpers.inputs_hash
      calculations = SummaryCalculations.report_calculations(period, accounts_summary[period], inputs)
      accounts_summary[period].concat(calculations)
    end
    accounts_summary
  end

  def self.pnl_inputs
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
