require_relative 'spec_helper'
require_relative '../tax_management/tax_checker'

describe TaxChecker do

  context 'draw in inputs from file' do

    it 'reads input figures for calculations' do
      result = TaxChecker.calculation_inputs
      expect(result).to be_a(Array)
      result.each_with_index do |item, i|
        expect(item).to be_a(Hash)
        expect(item.keys.sort).to eq(%w[period no_of_shares share_value PS12D S5B S22B].sort)
        item.values.each { |value| expect(value).to be_a(Fixnum) }
        expect(item['period']).to eq(i + 1)
      end
    end

  end

end