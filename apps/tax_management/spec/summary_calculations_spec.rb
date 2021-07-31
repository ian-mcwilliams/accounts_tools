require_relative 'spec_helper'
require_relative '../lib/summary_calculations'
require_relative 'support/summary_calculations_spec_helpers'

describe SummaryCalculations, :summary_calculations do

  context 'initial calculations' do

    it 'returns the basic set of calculations when given a zero accounts hash' do
      accounts = TaxCheckerSpecHelpers.zero_actual_account_array
      actual = SummaryCalculations.initial_calculations(accounts)
      expected = TaxCheckerSpecHelpers.initial_calculation_zero_array
      TaxCheckerSpecHelpers.verify_accounts_array(self, actual, expected)
    end

    it 'returns the basic set of calculations when given a non-zero accounts hash' do
      accounts = TaxCheckerSpecHelpers.non_zero_account_array
      actual = SummaryCalculations.initial_calculations(accounts)
      expected = TaxCheckerSpecHelpers.initial_calculation_non_zero_array
      TaxCheckerSpecHelpers.verify_accounts_array(self, actual, expected)
    end

  end

  context 'input calculations' do

    it 'returns the input calculations for the current period when given zero inputs' do
      inputs = TaxCheckerSpecHelpers.inputs_hash(true)
      inputs = { current: inputs, previous: inputs }
      actual = SummaryCalculations.input_calculations(:current, inputs)
      expected = TaxCheckerSpecHelpers.input_calculation_zero_array(:current)
      TaxCheckerSpecHelpers.verify_accounts_array(self, actual, expected)
    end

    it 'returns the input calculations for the previous period when given zero inputs' do
      inputs = TaxCheckerSpecHelpers.inputs_hash(true)
      inputs = { current: inputs, previous: inputs }
      actual = SummaryCalculations.input_calculations(:previous, inputs)
      expected = TaxCheckerSpecHelpers.input_calculation_zero_array(:previous)
      TaxCheckerSpecHelpers.verify_accounts_array(self, actual, expected)
    end

    it 'returns the input calculations for the current period when given non zero inputs' do
      inputs = { current: TaxCheckerSpecHelpers.inputs_hash, previous: TaxCheckerSpecHelpers.inputs_hash }
      inputs[:previous]['PS12D'] = 2
      actual = SummaryCalculations.input_calculations(:current, inputs)
      expected = TaxCheckerSpecHelpers.input_calculation_non_zero_array(:current)
      TaxCheckerSpecHelpers.verify_accounts_array(self, actual, expected)
    end

    it 'returns the input calculations for the previous period when given non zero inputs' do
      inputs = { current: TaxCheckerSpecHelpers.inputs_hash, previous: TaxCheckerSpecHelpers.inputs_hash }
      inputs[:previous]['PS12D'] = 2
      actual = SummaryCalculations.input_calculations(:previous, inputs)
      expected = TaxCheckerSpecHelpers.input_calculation_non_zero_array(:previous)
      TaxCheckerSpecHelpers.verify_accounts_array(self, actual, expected)
    end

  end

  context 'composite calculations' do

    it 'returns the composite calculations for the current period when given all zero accounts' do
      accounts = TaxCheckerSpecHelpers.zero_actual_account_array
      accounts.concat(TaxCheckerSpecHelpers.initial_calculation_zero_array)
      accounts.concat(TaxCheckerSpecHelpers.input_calculation_zero_array(:current))
      actual = SummaryCalculations.composite_calculations(:current, accounts)
      expected = TaxCheckerSpecHelpers.composite_calculation_zero_array
      TaxCheckerSpecHelpers.verify_accounts_array(self, actual, expected)
    end

    it 'returns the composite calculations for the previous period when given all zero accounts' do
      accounts = TaxCheckerSpecHelpers.zero_actual_account_array
      accounts.concat(TaxCheckerSpecHelpers.initial_calculation_zero_array)
      accounts.concat(TaxCheckerSpecHelpers.input_calculation_zero_array(:previous))
      actual = SummaryCalculations.composite_calculations(:previous, accounts)
      expected = TaxCheckerSpecHelpers.composite_calculation_zero_array
      TaxCheckerSpecHelpers.verify_accounts_array(self, actual, expected)
    end

    it 'returns the composite calculations for the current period when given non zero accounts' do
      accounts = TaxCheckerSpecHelpers.non_zero_account_array
      accounts.concat(TaxCheckerSpecHelpers.initial_calculation_non_zero_array)
      accounts.concat(TaxCheckerSpecHelpers.input_calculation_non_zero_array(:current))
      actual = SummaryCalculations.composite_calculations(:current, accounts)
      expected = TaxCheckerSpecHelpers.composite_calculation_non_zero_array(:current)
      TaxCheckerSpecHelpers.verify_accounts_array(self, actual, expected)
    end

    it 'returns the composite calculations for the previous period when given non zero accounts' do
      accounts = TaxCheckerSpecHelpers.non_zero_account_array
      accounts.concat(TaxCheckerSpecHelpers.initial_calculation_non_zero_array)
      accounts.concat(TaxCheckerSpecHelpers.input_calculation_non_zero_array(:previous))
      actual = SummaryCalculations.composite_calculations(:previous, accounts)
      expected = TaxCheckerSpecHelpers.composite_calculation_non_zero_array(:previous)
      TaxCheckerSpecHelpers.verify_accounts_array(self, actual, expected)
    end

  end

  context 'all calculations' do

    it 'returns the full calculations array for the current period' do
      accounts = TaxCheckerSpecHelpers.non_zero_account_array
      inputs = { current: TaxCheckerSpecHelpers.inputs_hash, previous: TaxCheckerSpecHelpers.inputs_hash }
      inputs[:previous]['PS12D'] = 2
      actual = SummaryCalculations.report_calculations(:current, accounts, inputs)
      expected = SummaryCalculationsSpecHelpers.all_calculations_non_zero_array(:current)
      TaxCheckerSpecHelpers.verify_accounts_array(self, actual, expected)
    end

    it 'returns the full calculations array for the previous period' do
      accounts = TaxCheckerSpecHelpers.non_zero_account_array
      inputs = { current: TaxCheckerSpecHelpers.inputs_hash, previous: TaxCheckerSpecHelpers.inputs_hash }
      inputs[:previous]['PS12D'] = 2
      actual = SummaryCalculations.report_calculations(:previous, accounts, inputs)
      expected = SummaryCalculationsSpecHelpers.all_calculations_non_zero_array(:previous)
      TaxCheckerSpecHelpers.verify_accounts_array(self, actual, expected)
    end

  end

end
