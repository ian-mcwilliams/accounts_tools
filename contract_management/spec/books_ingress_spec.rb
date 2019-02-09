require_relative 'spec_helper'
require_relative '../lib/books_ingress'

describe 'BooksIngress' do
  it 'returns a hash of files when given an excel file location' do
    actual = BooksIngress.import_books
    expect(actual.keys).to eq(%i[contracts sales_and_vat])
  end
end
