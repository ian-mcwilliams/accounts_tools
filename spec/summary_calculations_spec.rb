require_relative 'spec_helper'
require_relative '../tax_management/summary_calculations'

describe SummaryCalculations, :summary_calculations do

  it 'returns the basic set of calculations when given a zero accounts hash' do
    accounts_hash = TaxCheckerSpecHelpers.zero_actual_account_array
    result = SummaryCalculations.report_calculations(accounts_hash)
    expected = TaxCheckerSpecHelpers.expected_initial_zero_calculations
    expect(result).to be_a(Array)
    result.each do |result_account|
      expect(result_account).to eq(expected.select { |item| item[:account_code] == result_account[:account_code] }[0])
    end
  end

  it 'returns the basic set of calculations when given a non-zero accounts hash' do
    accounts_hash = TaxCheckerSpecHelpers.non_zero_account_array
    result = SummaryCalculations.report_calculations(accounts_hash)
    expected = TaxCheckerSpecHelpers.expected_initial_non_zero_calculations
    expect(result).to be_a(Array)
    result.each do |result_account|
      expect(result_account).to eq(expected.select { |item| item[:account_code] == result_account[:account_code] }[0])
    end
  end

end
