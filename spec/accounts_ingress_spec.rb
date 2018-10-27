require_relative 'spec_helper'
require_relative '../tax_management/accounts_ingress'

describe AccountsIngress do
  include TaxCheckerSpecHelpers

  it 'gets just the first period hash when period 1 specified' do
    accounts_hash = AccountsIngress.accounts_summaries_ingress(1, true)
    expect(accounts_hash.keys.sort).to eq(%i[previous_period current_period].sort)
    expect(accounts_hash[:previous_period]).to be(nil)
    expect(accounts_hash[:current_period].class).to be(Array)
    expected = TaxCheckerSpecHelpers.unbalanced_actual_account_array(400000)
    accounts_hash[:current_period].each_with_index do |account_hash, i|
      expect(account_hash).to eq(expected[i])
    end
  end

  it 'gets the first and second period hashes when period 2 specified' do
    accounts_hash = AccountsIngress.accounts_summaries_ingress(2, true)
    expect(accounts_hash.keys.sort).to eq(%i[previous_period current_period].sort)
    expect(accounts_hash[:previous_period].class).to be(Array)
    expected = TaxCheckerSpecHelpers.unbalanced_actual_account_array(400000)
    accounts_hash[:previous_period].each_with_index do |account_hash, i|
      expect(account_hash).to eq(expected[i])
    end
    expect(accounts_hash[:current_period].class).to be(Array)
    expected = TaxCheckerSpecHelpers.unbalanced_actual_account_array(100000)
    accounts_hash[:current_period].each_with_index do |account_hash, i|
      expect(account_hash).to eq(expected[i])
    end
  end

end