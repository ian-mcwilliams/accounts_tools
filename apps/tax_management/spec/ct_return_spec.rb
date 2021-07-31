require_relative 'spec_helper'
require_relative '../lib/ct_return'
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
    opening_balance = input_accounts[:previous][:accounts].find { |item| item[:account_code] == 'S23' }
    %i[cr balance].each { |key| opening_balance[key] = 10 }
    inputs = CtReturnSpecHelpers.reports_summary_inputs
    actual = CtReturn.ct_account_notes_inputs(input_accounts, inputs, inputs)
    expected = CtReturnSpecHelpers.ct_account_notes_hashes
    CtReturnSpecHelpers.verify_box_array(self, actual, expected)
  end

  it 'returns a computations hash when provided a full reports summary hash' do
    input_accounts = CtReturnSpecHelpers.input_accounts
    office_rent = input_accounts[:current][:accounts].find { |item| item[:account_code] == 'E16' }
    %i[dr balance].each { |key| office_rent[key] = 10 }
    actual = CtReturn.ct_computations_inputs(input_accounts)
    expected = CtReturnSpecHelpers.ct_computations_hashes
    CtReturnSpecHelpers.verify_box_array(self, actual, expected)
  end

  it 'returns a CT600 section hash when provided a full reports summary hash' do
    input_accounts = CtReturnSpecHelpers.input_accounts
    actual = CtReturn.ct_section_inputs(input_accounts)
    expected = CtReturnSpecHelpers.ct_section_hashes
    CtReturnSpecHelpers.verify_box_array(self, actual, expected)
  end

  it 'returns a full tax return inputs hash when provided a full reports summary hash' do
    input_accounts = CtReturnSpecHelpers.input_accounts
    opening_balance = input_accounts[:previous][:accounts].find { |item| item[:account_code] == 'S23' }
    %i[cr balance].each { |key| opening_balance[key] = 10 }
    office_rent = input_accounts[:current][:accounts].find { |item| item[:account_code] == 'E16' }
    %i[dr balance].each { |key| office_rent[key] = 10 }
    inputs = CtReturnSpecHelpers.reports_summary_inputs
    actual = CtReturn.corporation_tax_return_inputs(input_accounts, inputs, inputs)
    expected = CtReturnSpecHelpers.corporation_tax_return_hashes
    CtReturnSpecHelpers.verify_box_array(self, actual, expected)
  end

end