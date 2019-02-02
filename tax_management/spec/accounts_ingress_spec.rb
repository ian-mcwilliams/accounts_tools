require_relative 'spec_helper'
require_relative '../lib/accounts_ingress'
require_relative 'support/accounts_ingress_spec_helpers'

describe AccountsIngress do

  it 'gets just the first period hash when period 1 specified' do
    accounts_hash = AccountsIngress.accounts_summaries_ingress(1, true)
    expect(accounts_hash.keys.sort).to eq(%i[previous current].sort)
    expect(accounts_hash[:previous]).to be(nil)
    expect(accounts_hash[:current].class).to be(Array)
    expected = AccountsIngressSpecHelpers.unbalanced_actual_account_array(400000)
    accounts_hash[:current].each_with_index do |account_hash, i|
      expect(account_hash).to eq(expected[i])
    end
  end

  it 'gets the first and second period hashes when period 2 specified' do
    accounts_hash = AccountsIngress.accounts_summaries_ingress(2, true)
    expect(accounts_hash.keys.sort).to eq(%i[previous current].sort)
    expect(accounts_hash[:previous].class).to be(Array)
    expected = AccountsIngressSpecHelpers.unbalanced_actual_account_array(400000)
    accounts_hash[:previous].each_with_index do |account_hash, i|
      expect(account_hash).to eq(expected[i])
    end
    expect(accounts_hash[:current].class).to be(Array)
    expected = AccountsIngressSpecHelpers.unbalanced_actual_account_array(100000)
    accounts_hash[:current].each_with_index do |account_hash, i|
      expect(account_hash).to eq(expected[i])
    end
  end

end