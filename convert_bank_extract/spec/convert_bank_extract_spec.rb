require_relative '../lib/convert_bank_extract'
require_relative 'spec_helper'

describe 'ConvertBankExtract' do
  SAVE_FILEPATH = ENV['CONVERT_BANK_EXTRACT_SAVE_FILEPATH']

  after(:all) do
    File.delete(SAVE_FILEPATH) if File.exist?(SAVE_FILEPATH)
  end

  context 'integration tests' do

    it 'saves an excel file built from csv data' do
      ConvertBankExtract.convert_bank_extract
      workbook = Rxl.read_file(SAVE_FILEPATH)
      expect(workbook.keys).to eq(['output'])
      expected = ConvertBankExtractSpecHelpers.integration_test_hashes
      expect(workbook['output'].count).to eq(expected.count)
      actual_values = {}
      workbook['output'].each { |key, value| actual_values[key] = { value: value[:value] } }
      expect(actual_values).to eq(expected)
    end

  end

  context 'unit tests' do

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

    it 'sorts the hashes by ascending date' do
      hashes = ConvertBankExtractSpecHelpers.test_hashes
      return_value = ConvertBankExtract.sorted_hashes(hashes)
      expect(return_value[0][:date]).to eq('01/01/2016')
      expect(return_value[2][:date]).to eq('10/01/2016')
    end

    it 'saves the hashes to file' do
      hashes = ConvertBankExtractSpecHelpers.test_hashes
      ConvertBankExtract.create_excel_file(ConvertBankExtract.sorted_hashes(hashes))
      expect(File.exist?(SAVE_FILEPATH)).to be(true)
    end

  end

end
