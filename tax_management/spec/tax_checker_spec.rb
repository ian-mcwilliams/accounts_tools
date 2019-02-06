require_relative 'spec_helper'
require_relative '../lib/tax_checker'
require_relative 'support/reports_summary_spec_helpers'

describe TaxChecker do

  context 'draw in inputs from file' do

    it 'throws an exception if the period is less than 1' do
      [0, -1].each do |period|
        message = "the period must be greater than 0 - got #{period}"
        expect { TaxChecker.calculation_inputs(period) }.to raise_error(message)
      end
    end

    it 'reads input figures for calculations with period set to 1' do
      result = TaxChecker.calculation_inputs(1)
      expect(result).to be_a(Hash)
      expect(result.keys).to eq(%i[current])
      expect(result[:current]).to be_a(Hash)
      expect(result[:current].keys.sort).to eq(%w[period no_of_shares share_value PS12D S5B S22B].sort)
      result[:current].values.each { |value| expect(value).to be_a(Fixnum) }
      expect(result[:current]['period']).to eq(1)
    end

    it 'reads input figures for calculations with period greater than 1' do
      result = TaxChecker.calculation_inputs(2)
      expect(result).to be_a(Hash)
      expect(result.keys).to eq(%i[current previous])
      %i[current previous].each do |period|
        expect(result[period]).to be_a(Hash)
        expect(result[period].keys.sort).to eq(%w[period no_of_shares share_value PS12D S5B S22B].sort)
        result[period].values.each { |value| expect(value).to be_a(Fixnum) }
        expect(result[period]['period']).to eq({ current: 2, previous: 1 }[period])
      end
    end

  end

  context 'when generating outputs' do

    it 'should generate a reports summary' do
      expected = ReportsSummarySpecHelpers.full_reports_summary_balanced_output
      inputs = {current: TaxCheckerSpecHelpers.inputs_hash, previous: TaxCheckerSpecHelpers.inputs_hash}
      actual = TaxChecker.generate_reports_summary(4, inputs, true)
      TaxCheckerSpecHelpers.verify_reports_summary(self, actual, expected)
    end

    it 'should generate companies house abbreviated accounts' do
      expected = TaxCheckerSpecHelpers.abbreviated_accounts_hash
      inputs = {current: TaxCheckerSpecHelpers.inputs_hash, previous: TaxCheckerSpecHelpers.inputs_hash}
      actual = TaxChecker.generate_ch_accounts(4, inputs, true)
      expect(actual).to be_a(Hash)
      expect(actual.keys.sort).to eq([:current, :previous])
      %i[current previous].each do |period|
        expect(actual[period]).to eq(expected[period])
      end
    end

    it 'should generate corporation tax return inputs' do
      expected = TaxCheckerSpecHelpers.ct_return_inputs_array
      inputs = {current: TaxCheckerSpecHelpers.inputs_hash, previous: TaxCheckerSpecHelpers.inputs_hash}
      actual = TaxChecker.generate_ct_return_inputs(4, inputs, true)
      expect(actual).to be_a(Array)
      expect(actual.length).to eq(expected.length)
      expected.each do |item|
        expect(actual).to include(item)
      end
    end

  end

end
