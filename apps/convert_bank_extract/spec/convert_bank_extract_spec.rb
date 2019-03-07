require_relative 'spec_helper'
require_relative '../lib/convert_bank_extract'

describe 'ConvertBankExtract' do

  before(:each) do
    ConvertBankExtractSpecHelpers.restore_test_state(state: :setup)
  end

  after(:each) do
    ConvertBankExtractSpecHelpers.restore_test_state
  end

  at_exit do
    ConvertBankExtractSpecHelpers.restore_test_state
  end

  context 'integration tests' do

    it 'throws an error if a file is missing' do
      FileUtils.rm(CONFIG['bank_book_filepath'])
      expected = "bank book not found at path: #{CONFIG['bank_book_filepath']}"
      expect { ConvertBankExtract.convert_bank_extract }.to raise_error(expected)
    end

    it 'builds a write hash' do
      bank_book = ConvertBankExtractSpecHelpers.test_bank_book_hashes
      hashes = ConvertBankExtractSpecHelpers.test_processed_csv_hashes
      write_hash = ConvertBankExtract.build_write_hash(bank_book, hashes)
      expect(write_hash.keys).to eq(['bank', :formats])
      expect(write_hash['bank']).to be_a(Array)
      expect(write_hash[:formats].keys).to eq(['bank'])
      expect(write_hash[:formats]['bank'].keys).to eq([:headers, 'A', 'D', 'E', 'F', 'G'])
    end

    it 'saves an excel file built from csv data' do
      ConvertBankExtract.convert_bank_extract
      workbook = Rxl.read_file_as_tables(CONFIG['bank_book_filepath'])
      expect(workbook.keys).to eq(['bank'])
      expect(workbook['bank'].count).to eq(16)
      expect(workbook['bank'][0]['id']).to eq(1)
      expect(workbook['bank'][-1]['id']).to eq(16)
      expect(workbook['bank'][-1]['balance']).to eq(3892.05)
      archive_filename = ConvertBankExtractSpecHelpers.dir_filenames(CONFIG['bank_book_archive_path'])[0]
      archive = Rxl.read_file_as_tables("#{CONFIG['bank_book_archive_path']}#{archive_filename}")
      expect(archive.keys).to eq(['bank'])
      expect(archive['bank'].count).to eq(13)
      expect(archive['bank'][-1]['id']).to eq(13)
    end

    it 'archives the bank statement as part of the process' do
      ConvertBankExtract.convert_bank_extract
      expect(File.exists?("#{CONFIG['bank_statements_path']}08046_170101-170110_8-3.pdf")).to be(true)
      expect(File.exists?("#{CONFIG['bank_statement_filepath']}E-Statements.pdf")).to be(false)
    end

    it 'archives the source file after completing the process' do
      data_csv_archive_path = CONFIG['data_csv_archive_path']
      archive_count = Dir["#{data_csv_archive_path}/*"].length
      ConvertBankExtract.convert_bank_extract
      expect(File.exist?("#{CONFIG['bank_extract_filepath']}")).to be(false)
      new_archive_count = Dir["#{data_csv_archive_path}/*"].length
      expect(new_archive_count).to eq(archive_count + 1)
    end

  end

  context 'unit tests' do

    context 'verify presence of required files' do

      it 'throws an error if the bank book is missing' do
        FileUtils.rm(CONFIG['bank_book_filepath'])
        expected = "bank book not found at path: #{CONFIG['bank_book_filepath']}"
        expect { ConvertBankExtract.verify_file_presence }.to raise_error(expected)
      end

      it 'throws an error if the csv is missing' do
        FileUtils.rm(CONFIG['bank_extract_filepath'])
        expected = "bank extract csv not found at path: #{CONFIG['bank_extract_filepath']}"
        expect { ConvertBankExtract.verify_file_presence }.to raise_error(expected)
      end

      it 'throws an error if the pdf is missing' do
        FileUtils.rm(CONFIG['bank_statement_filepath'])
        expected = "bank statement pdf not found at path: #{CONFIG['bank_statement_filepath']}"
        expect { ConvertBankExtract.verify_file_presence }.to raise_error(expected)
      end

    end

    context 'import files to memory' do

      it 'loads the current bank book file into memory' do
        file = ConvertBankExtract.load_file(:bank_book)
        expect(file.class).to be(Array)
        expect(file[0].keys).to eq(%w[id period statement date debit credit balance subcat description])
        expect(file[0]['date']).to be_a(DateTime)
      end

      it 'loads the CSV file into memory' do
        file = ConvertBankExtract.load_file(:csv)
        expect(file.class).to be(Array)
        file.each do |row|
          expect(row[1]).to match(/^\d\d\/\d\d\/\d\d\d\d$/)
          expect(row[2]).to match(/^\d\d-\d\d-\d\d\s\d\d\d\d\d\d\d\d$/)
          expect(row[3]).to match(/^-?\d+\.\d\d$/)
          expect(row[4]).to be_a(String)
          expect(row[4]).not_to be_empty
          expect(row[5]).to be_a(String)
          expect(row[5]).not_to be_empty
        end
      end

      it 'throws an error if the file key is not recognised' do
        expect{ ConvertBankExtract.load_file(:fake_key) }.to raise_error("file_key 'fake_key' not recognised")
      end

    end

    it 'returns hashes for each row' do
      file = ConvertBankExtractSpecHelpers.test_raw_csv_hashes
      hashes = ConvertBankExtract.build_hashes(file, 1, '600.00')
      hashes.each do |h|
        expect(h['id']).to be_a(Fixnum)
        expect(h['period']).to match(/^\d+-\d+$/)
        expect(h['statement']).to match(/^08046_\d{6}-\d{6}$/)
        expect(h['date']).to be_a(DateTime)
        if h['credit']
          expect(h['debit']).to be_nil
        else
          expect(h['debit']).to be_a(Float)
          expect(h['debit'].to_s).to match(/^\d+\.\d+$/)
        end
        if h['debit']
          expect(h['credit']).to be_nil
        else
          expect(h['credit']).to be_a(Float)
          expect(h['credit'].to_s).to match(/^\d+\.\d+$/)
        end
        expect(h['balance']).to be_a(Float)
        expect(h['balance'].to_s).to match(/^\d+\.\d+$/)
        expect(h['subcat']).to be_a(String)
        expect(h['subcat']).not_to be_empty
        expect(h['description']).to be_a(String)
        expect(h['description']).not_to be_empty
      end
    end

    it 'sets the period correctly for each new row' do
      raw_csv_hashes = ConvertBankExtractSpecHelpers.test_raw_csv_hashes
      hashes = ConvertBankExtract.build_hashes(raw_csv_hashes, 1, '600.00')
      actual = hashes.map { |h| h['period'] }
      expect(actual).to eq(%w[8-1 8-2 8-3])
    end

    context 'returns the company period when given a full date string' do
      tests = [
        { date: '08/09/2010', expected: '1-1' },
        { date: '01/01/2011', expected: '1-5' },
        { date: '30/09/2011', expected: '2-1' },
        { date: '08/11/2011', expected: '3-1' },
        { date: '01/01/2012', expected: '3-3' },
        { date: '08/10/2012', expected: '3-12' },
        { date: '08/11/2012', expected: '4-1' }
      ]
      tests.each do |test|
        it "as #{test[:date]}" do
          actual = ConvertBankExtract.generate_period_string(test[:date])
          expect(actual).to eq(test[:expected])
        end
      end
    end

    it 'archives the existing bank book' do
      archive_filename = "bank_archive_#{DateTime.now.strftime('%y%m%d%H%M%S')}.xlsx"
      archive_bank_book_filepath = "#{CONFIG['bank_book_archive_path']}#{archive_filename}"
      ConvertBankExtract.archive_current_bank_book(archive_filename)
      expect(File.exist?(CONFIG['bank_book_filepath'])).to be(false)
      expect(File.exist?(archive_bank_book_filepath)).to be(true)
    end

    it 'creates the new bank book file' do
      hashes = ConvertBankExtractSpecHelpers.test_bank_book_hashes
      filepath = CONFIG['bank_book_filepath'].gsub('bank.xlsx', 'test_bank.xlsx')
      write_hash = { 'bank' => hashes }
      ConvertBankExtract.create_excel_file(filepath, write_hash)
      expect(File.exist?(filepath)).to be(true)
    end

    it 'archives the bank statement' do
      filename = 'bank_statement_filename.pdf'
      ConvertBankExtract.archive_bank_statement(filename)
      expect(File.exists?("#{CONFIG['bank_statements_path']}#{filename}")).to be(true)
      expect(File.exists?("#{CONFIG['bank_statement_filepath']}#{filename}")).to be(false)
    end

    it 'archives the source csv file after process complete' do
      filename = 'data_csv_filename.pdf'
      ConvertBankExtract.archive_data_csv_file(filename)
      expect(File.exist?("#{CONFIG['bank_extract_filepath']}#{filename}")).to be(false)
      expect(File.exist?("#{CONFIG['data_csv_archive_path']}#{filename}")).to be(true)
    end

    it 'returns a hash of archive filenames' do
      hashes = [
        { 'date' => DateTime.parse('13/05/2017') },
        { 'date' => DateTime.parse('01/01/2014') },
        { 'date' => DateTime.parse('25/07/2019') }
      ]
      actual = ConvertBankExtract.generate_archive_filenames(hashes)
      expect(actual.keys.sort).to eq(%i[bank data_csv statement])
      expect(actual[:bank]).to match(/^bank_archive_8-7_\d{12}.xlsx$/)
      expect(actual[:statement]).to eq("#{CONFIG['bank_prefix']}_170513-190725_8-7.pdf")
      expect(actual[:data_csv]).to match(/^data_csv_archive_8-7_\d{12}.csv$/)
    end

    context 'pounds to pence' do
      tests = [
        { input: nil, expected: 0 },
        { input: 0, expected: 0 },
        { input: 1, expected: 100 },
        { input: 100, expected: 10000 },
        { input: -1, expected: -100 },
        { input: 0.0, expected: 0 },
        { input: 0.01, expected: 1 },
        { input: 0.1, expected: 10 },
        { input: 1.0, expected: 100 },
        { input: 1.01, expected: 101 },
        { input: '', expected: 0 },
        { input: '.', expected: 0 },
        { input: '0', expected: 0 },
        { input: '.0', expected: 0 },
        { input: '.00', expected: 0 },
        { input: '0.', expected: 0 },
        { input: '0.0', expected: 0 },
        { input: '0.00', expected: 0 },
        { input: '0.01', expected: 1 },
        { input: '.1', expected: 10 },
        { input: '0.1', expected: 10 },
        { input: '0.10', expected: 10 },
        { input: '1', expected: 100 },
        { input: '1.', expected: 100 },
        { input: '1.0', expected: 100 },
        { input: '1.00', expected: 100 },
        { input: '1.01', expected: 101 },
        { input: '1.1', expected: 110 },
        { input: '1.10', expected: 110 },
        { input: '-.', expected: 0 },
        { input: '-0', expected: 0 },
        { input: '-0.', expected: 0 },
        { input: '-.0', expected: 0 },
        { input: '-.00', expected: 0 },
        { input: '-0.01', expected: -1 },
        { input: '-0.1', expected: -10 },
        { input: '-1', expected: -100 },
        { input: '-1.01', expected: -101 }
      ]
      tests.each do |test|
        it "returns the correct result when passed a #{test[:input].class} as #{test[:input]}" do
          expect(ConvertBankExtract.pounds_to_pence(test[:input])).to eq(test[:expected])
        end
      end
    end

    context 'pounds to pence exceptions' do
      tests = [
        0.001,
        0.99999,
        1.001,
        1.99999,
        '.000',
        '0.000',
        '0.001',
        '0.99999',
        '1.001',
        '1.99999'
      ]
      tests.each do |test|
        it "throws an exception when given more than 2 decimal places, example #{test.class} as #{test}" do
          msg = "max 2 decimal places allowed, got: #{test}"
          expect { ConvertBankExtract.pounds_to_pence(test) }.to raise_error(msg)
        end
      end

      tests = [
        '..',
        ' ',
        '12_3',
        'abc',
        '£100',
        '$1.10'
      ]
      tests.each do |test|
        it "throws an exception if the input is a string without being in a valid number format, example #{test}" do
          msg = "string must be a valid number or float format, got: #{test}"
          expect { ConvertBankExtract.pounds_to_pence(test) }.to raise_error(msg)
        end
      end

      tests = [
        DateTime.now,
        [],
        [0],
        {},
        { value: 0.01 }
      ]
      tests.each do |test|
        it "throws an exception if the class is not convertible" do
          msg = "class not valid: #{test.class}"
          expect { ConvertBankExtract.pounds_to_pence(test) }.to raise_error(msg)
        end
      end
    end

  end

end
