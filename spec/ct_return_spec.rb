require_relative 'spec_helper'
require_relative '../tax_management/ct_return'
require_relative 'support/ct_return_spec_helpers'

describe CtReturn do

  it 'returns a profit and loss hash when provided a full reports summery hash' do
    input_accounts = CtReturnSpecHelpers.input_accounts
    actual = CtReturn.ct_profit_and_loss(input_accounts)
    expected = CtReturnSpecHelpers.ct_profit_and_loss_hashes
    CtReturnSpecHelpers.verify_box_array(self, actual, expected)
  end

  it 'returns a balance sheet hash when provided a full reports summary hash' do
    input_accounts = CtReturnSpecHelpers.input_accounts
    actual = CtReturn.ct_balance_sheet_inputs(input_accounts)
    expected = CtReturnSpecHelpers.ct_balance_sheet_hashes
    CtReturnSpecHelpers.verify_box_array(self, actual, expected)
  end

  it 'returns an accounts notes hash when provided a full reports summary hash' do
    input_accounts = CtReturnSpecHelpers.input_accounts
    inputs = CtReturnSpecHelpers.reports_summary_inputs
    actual = CtReturn.ct_account_notes_inputs(input_accounts, inputs, inputs)
    expected = CtReturnSpecHelpers.ct_account_notes_hashes
    CtReturnSpecHelpers.verify_box_array(self, actual, expected)
  end

  it 'returns a computations hash when provided a full reports summary hash' do
    input_accounts = CtReturnSpecHelpers.input_accounts
    actual = CtReturn.ct_computations_inputs(input_accounts)
    expected = CtReturnSpecHelpers.ct_computations_hashes
    CtReturnSpecHelpers.verify_box_array(self, actual, expected)
  end

end