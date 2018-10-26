require_relative '../tax_management/accounts_ingress'
require_relative 'spec_helpers'
require 'rspec'

describe AccountsIngress do
  include TaxCheckerSpecHelpers

  it 'gets just the first period hash when period 1 specified' do
    accounts_hash = AccountsIngress.accounts_summaries_ingress(1, true)
    expect(accounts_hash.keys.sort).to eq(%i[previous_period current_period].sort)
    expect(accounts_hash[:previous_period]).to be(nil)
    expect(accounts_hash[:current_period].class).to be(Array)
    expected = TaxCheckerSpecHelpers.test_expected_hash_array_a
    accounts_hash[:current_period].each_with_index do |account_hash, i|
      expect(account_hash).to eq(expected[i])
    end
  end

  it 'gets the first and second period hashes when period 2 specified' do
    accounts_hash = AccountsIngress.accounts_summaries_ingress(2, true)
    expect(accounts_hash.keys.sort).to eq(%i[previous_period current_period].sort)
    expect(accounts_hash[:previous_period].class).to be(Array)
    expected = TaxCheckerSpecHelpers.test_expected_hash_array_a
    accounts_hash[:previous_period].each_with_index do |account_hash, i|
      expect(account_hash).to eq(expected[i])
    end
    expect(accounts_hash[:current_period].class).to be(Array)
    expected = TaxCheckerSpecHelpers.test_expected_hash_array_b
    accounts_hash[:current_period].each_with_index do |account_hash, i|
      expect(account_hash).to eq(expected[i])
    end
  end

end