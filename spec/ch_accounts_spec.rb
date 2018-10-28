require_relative 'spec_helper'
require_relative '../tax_management/ch_accounts'
require_relative 'support/ch_accounts_spec_helpers'

describe ChAccounts do

  it 'returns a full abbreviated accounts hash when provided with the required inputs' do
    accounts = ChAccountsSpecHelpers.abbreviated_accounts_input_accounts
    actual = ChAccounts.abbreviated_accounts(accounts)
    expected = ChAccountsSpecHelpers.abbreviated_accounts_hash
    expect(actual).to eq(expected)
  end

  it 'returns errors only if the total net assets and shareholders funds do not match' do
    ChAccountsSpecHelpers.ch_verify_accounts_tests.each do |test|
      actual = ChAccounts.verify_accounts(test[:inputs])
      expect(actual).to eq(test[:expected])
    end
  end

end