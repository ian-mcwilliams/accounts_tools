require_relative 'spec_helper'
require_relative '../tax_management/ct_return'
require_relative 'support/ct_return_spec_helpers'

describe CtReturn do

  it 'returns a profit and loss hash when provided a full reports summery hash' do
    input_accounts = CtReturnSpecHelpers.input_accounts
    actual = CtReturn.pnl_inputs(input_accounts)
    expected = CtReturnSpecHelpers.pnl_inputs
    expect(actual.map { |item| item[:box] }).to eq(expected.map { |item| item[:box] })
    expected.each { |item| expect(actual).to include(item) }
  end

end