require_relative 'spec_helper'
require_relative '../lib/books_ingress'

describe 'BooksIngress' do
  it 'returns a hash of files when given an excel file location' do
    actual = BooksIngress.import_books
    expected_keys = %i[
      contracts
      sales_and_vat
      timesheets
    ]
    expect(actual.keys.sort).to eq(expected_keys.sort)
  end
end
