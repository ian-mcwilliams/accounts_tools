require_relative 'spec_helper'
require_relative '../tax_management/reports_summary'
require_relative 'support/reports_summary_spec_helpers'

describe ReportsSummary do

  context 'reports_summary' do

    it 'returns all accounts, balances and summary accounts for the current and previous period' do
      inputs = TaxCheckerSpecHelpers.inputs_hash
      accounts_hash = {
        current: TaxCheckerSpecHelpers.non_zero_account_array,
        previous: TaxCheckerSpecHelpers.non_zero_account_array
      }
      actual = ReportsSummary.reports_summary(accounts_hash, inputs)
      expected = ReportsSummarySpecHelpers.full_reports_summary_balanced_output
      expect(actual).to be_a(Hash)
      expect(actual.keys.sort).to eq(expected.keys.sort)
      TaxCheckerSpecHelpers.verify_reports_summary(self, actual, expected)
    end

  end

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

end