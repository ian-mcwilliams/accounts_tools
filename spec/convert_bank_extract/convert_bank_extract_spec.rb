require_relative '../../convert_bank_extract/convert_bank_extract'
require_relative 'spec_helper'

describe 'ConvertBankExtract' do

  it 'loads the file into memory' do
    file = ConvertBankExtract.load_file
    expect(file.class).to be(Array)
    file.each_with_index do |row, i|
      expect(row[1]).to match(/^\d\d\/\d\d\/\d\d\d\d$/)
      expect(row[2]).to match(/^\d\d-\d\d-\d\d\s\d\d\d\d\d\d\d\d$/)
      expect(row[3]).to match(/^-?\d+\.\d\d$/)
      expect(row[4]).to be_a(String)
      expect(row[4]).not_to be_empty
      expect(row[5]).to be_a(String)
      expect(row[5]).not_to be_empty
    end
  end

  it 'returns hashes for each row' do
    file = ConvertBankExtract.load_file
    hashes = ConvertBankExtract.build_hashes(file)
    hashes.each do |hash|
      expect(hash[:date]).to match(/^\d\d\/\d\d\/\d\d\d\d$/)
      expect(hash[:debit]).to hash[:credit] ? be_nil : match(/^\d+\.\d\d$/)
      expect(hash[:credit]).to hash[:debit] ? be_nil : match(/^\d+\.\d\d$/)
      expect(hash[:subcat]).to be_a(String)
      expect(hash[:subcat]).not_to be_empty
      expect(hash[:description]).to be_a(String)
      expect(hash[:description]).not_to be_empty
    end
  end

  it 'returns a new axlsx object' do
    return_value = ConvertBankExtract.new_excel_file
    expect(return_value).to be_a(Axlsx::Package)
    expect(return_value.workbook.worksheets.count).to be(1)
    expect(return_value.workbook.worksheets[0].name).to eq('output')
  end

end
