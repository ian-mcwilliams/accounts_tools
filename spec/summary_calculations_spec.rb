require_relative '../tax_management/summary_calculations'
require_relative 'spec_helpers'

describe SummaryCalculations do

  it 'returns the basic set of calculations when given a zero accounts hash' do
    accounts_hash = TaxCheckerSpecHelpers.zero_actual_account_array
    result = SummaryCalculations.report_calculations(accounts_hash)
    expected = TaxCheckerSpecHelpers.expected_initial_calculations
    expect(result).to eq(expected)
  end

end