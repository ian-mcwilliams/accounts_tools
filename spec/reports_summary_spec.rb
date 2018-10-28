require_relative 'spec_helper'
require_relative '../tax_management/reports_summary'

describe ReportsSummary do

  context 'validate account' do

    it 'does not raise an exception when the credit and debit figures balance to the balance figure' do
      summary_array = [
        { account_name: 'test_account', account_balance: :dr, dr: 100, cr: 100, balance: 0 },
        { account_name: 'test_account', account_balance: :dr, dr: 200, cr: 100, balance: 100 },
        { account_name: 'test_account', account_balance: :dr, dr: 100, cr: 200, balance: -100 },
        { account_name: 'test_account', account_balance: :cr, dr: 100, cr: 100, balance: 0 },
        { account_name: 'test_account', account_balance: :cr, dr: 200, cr: 100, balance: -100 },
        { account_name: 'test_account', account_balance: :cr, dr: 100, cr: 200, balance: 100 },
      ]
      expect { ReportsSummary.accounts_summary_validation(summary_array) }.not_to raise_error
    end

    it 'returns an exception when the specified dr, cr and balance are mismatched for a dr account' do
      summary_array = [
        { account_name: 'test_account', account_balance: :dr, dr: 100, cr: 100, balance: 1 }
      ]
      error_message = "summary validation failed for account 'test_account'"
      expect { ReportsSummary.accounts_summary_validation(summary_array) }.to raise_error(error_message)
    end

    it 'returns an exception when the specified dr, cr and balance are mismatched for a dr account' do
      summary_array = [
        { account_name: 'test_account', account_balance: :cr, dr: 100, cr: 100, balance: 1 }
      ]
      error_message = "summary validation failed for account 'test_account'"
      expect { ReportsSummary.accounts_summary_validation(summary_array) }.to raise_error(error_message)
    end

  end

  context 'get accounts balance hash' do

    it 'returns a hash of the assets, liabilities and equity balances' do
      expected = { assets: -150, equity: -60, liabilities: 250 }
      summary_array = TaxCheckerSpecHelpers.test_simple_unbalanced_hash_array
      result = ReportsSummary.accounts_balances_hash(summary_array)
      expect(result).to eq(expected)
    end

  end

  context 'validate accounting equation' do

    it 'raises an exception when the accounting equation fails' do
      sample_hashes = [
        { assets: 0, liabilities: 1, equity: 2 },
        { assets: 0, liabilities: 1, equity: 0 }
      ]
      sample_hashes.each do |sample_hash|
        assets_less_liabilities = sample_hash[:assets] + sample_hash[:liabilities]
        error_message = "assets less liabilities (#{assets_less_liabilities}) is not equal to equity (#{sample_hash[:equity]}) for test_period"
        expect { ReportsSummary.accounts_balances_validation('test_period', sample_hash) }.to raise_error(error_message)
      end
    end

    it 'does not raise an exception when the accounting equation passes' do
      sample_hash = { assets: 0, liabilities: 1, equity: 1 }
      expect { ReportsSummary.accounts_balances_validation('test_period', sample_hash) }.not_to raise_error
    end

  end

  context 'draw in inputs from file' do

    it 'reads input figures for calculations' do
      result = ReportsSummary.calculation_inputs
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