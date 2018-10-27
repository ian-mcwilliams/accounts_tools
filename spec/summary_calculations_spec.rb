require_relative 'spec_helper'
require_relative '../tax_management/summary_calculations'

describe SummaryCalculations, :summary_calculations do

  it 'returns the basic set of calculations when given a zero accounts hash' do
    accounts = TaxCheckerSpecHelpers.zero_actual_account_array
    result = SummaryCalculations.initial_calculations(accounts)
    expected = TaxCheckerSpecHelpers.initial_calculation_zero_array
    expect(result).to be_a(Array)
    expect(result.map { |item| item[:account_code] }.sort).to eq(expected.map { |item| item[:account_code] }.sort)
    expected.each do |account|
      expect(account).to eq(expected.select { |item| item[:account_code] == account[:account_code] }[0])
    end
  end

  it 'returns the basic set of calculations when given a non-zero accounts hash' do
    accounts = TaxCheckerSpecHelpers.non_zero_account_array
    result = SummaryCalculations.initial_calculations(accounts)
    expected = TaxCheckerSpecHelpers.expected_initial_non_zero_calculations
    expect(result).to be_a(Array)
    expect(result.map { |item| item[:account_code] }.sort).to eq(expected.map { |item| item[:account_code] }.sort)
    expected.each do |account|
      expect(account).to eq(expected.select { |item| item[:account_code] == account[:account_code] }[0])
    end
  end

  it 'returns the input calculations for the current period when given zero inputs' do
    inputs = { 'S5C' => 0, 'S7C' => 0, 'S22C' => 0 }
    result = SummaryCalculations.input_calculations(:current, inputs)
    expected = TaxCheckerSpecHelpers.input_calculation_zero_array(:current)
    expect(result).to be_a(Array)
    expect(result.map { |item| item[:account_code] }.sort).to eq(expected.map { |item| item[:account_code] }.sort)
    expected.each do |account|
      expect(account).to eq(expected.select { |item| item[:account_code] == account[:account_code] }[0])
    end
  end

  it 'returns the input calculations for the previous period when given zero inputs' do
    inputs = { 'S5C' => 0, 'S7C' => 0, 'S12D' => 0, 'S22C' => 0 }
    result = SummaryCalculations.input_calculations(:previous, inputs)
    expected = TaxCheckerSpecHelpers.input_calculation_zero_array(:previous)
    expect(result).to be_a(Array)
    expect(result.map { |item| item[:account_code] }.sort).to eq(expected.map { |item| item[:account_code] }.sort)
    expected.each do |account|
      expect(account).to eq(expected.select { |item| item[:account_code] == account[:account_code] }[0])
    end
  end

  it 'returns the input calculations for the current period when given non zero inputs' do
    inputs = { 'S5C' => 1, 'S7C' => 0, 'S22C' => 1 }
    result = SummaryCalculations.input_calculations(:current, inputs)
    expected = TaxCheckerSpecHelpers.input_calculation_non_zero_array(:current)
    expect(result).to be_a(Array)
    expect(result.map { |item| item[:account_code] }.sort).to eq(expected.map { |item| item[:account_code] }.sort)
    expected.each do |account|
      expect(account).to eq(expected.select { |item| item[:account_code] == account[:account_code] }[0])
    end
  end

  it 'returns the input calculations for the previous period when given non zero inputs' do
    inputs = { 'S5C' => 1, 'S7C' => 0, 'S12D' => 1, 'S22C' => 1 }
    result = SummaryCalculations.input_calculations(:previous, inputs)
    expected = TaxCheckerSpecHelpers.input_calculation_non_zero_array(:previous)
    expect(result).to be_a(Array)
    expect(result.map { |item| item[:account_code] }.sort).to eq(expected.map { |item| item[:account_code] }.sort)
    expected.each do |account|
      expect(account).to eq(expected.select { |item| item[:account_code] == account[:account_code] }[0])
    end
  end

  it 'returns the composite calculations for the current period when given all zero accounts' do
    accounts = TaxCheckerSpecHelpers.zero_actual_account_array
    accounts.concat(TaxCheckerSpecHelpers.initial_calculation_zero_array)
    accounts.concat(TaxCheckerSpecHelpers.input_calculation_zero_array(:current))
    result = SummaryCalculations.composite_calculations(:current, accounts)
    expected = TaxCheckerSpecHelpers.composite_calculation_zero_array
    expect(result).to be_a(Array)
    expect(result.map { |item| item[:account_code] }.sort).to eq(expected.map { |item| item[:account_code] }.sort)
    expected.each do |account|
      expect(account).to eq(expected.select { |item| item[:account_code] == account[:account_code] }[0])
    end
  end

end
