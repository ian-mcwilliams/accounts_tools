module ConvertBankExtractSpecHelpers

  def self.test_hashes
    [
      {
        id: 1,
        period: '1-1',
        statement: '12345_123456-123456',
        date: '10/01/2016',
        debit: nil,
        credit: '100.00',
        balance: '100.00',
        subcat: 'ABC',
        description: 'XYZ'
      },
      {
        id: 2,
        period: '1-1',
        statement: '12345_123456-123456',
        date: '05/01/2016',
        debit: nil,
        credit: '200.00',
        balance: '300.00',
        subcat: 'DEF',
        description: 'UVW'
      },
      {
        id: 3,
        period: '1-1',
        statement: '12345_123456-123456',
        date: '01/01/2016',
        debit: '50.00',
        credit: nil,
        balance: '250.00',
        subcat: 'GHI',
        description: 'RST'
      }
    ]
  end

  def self.restore_test_state(state: :clear)
    test_files_path = 'apps/convert_bank_extract/spec/support/test_files/'
    bookkeeping_path = "#{test_files_path}bookkeeping"
    source_files_path = "#{test_files_path}source_files"
    records_path = "#{test_files_path}records"
    FileUtils.rm_rf(bookkeeping_path)
    FileUtils.rm_rf(source_files_path)
    FileUtils.rm_rf(records_path)
    if state == :setup
      FileUtils.mkdir_p(bookkeeping_path)
      FileUtils.mkdir_p(source_files_path)
      FileUtils.mkdir_p(records_path)
      FileUtils.cp("#{test_files_path}bank.xlsx", bookkeeping_path)
      FileUtils.cp("#{test_files_path}data.csv", source_files_path)
      FileUtils.cp("#{test_files_path}E-Statement.pdf", source_files_path)
    end
  end

  def self.dir_filenames(path)
    filenames = Dir.entries(path)
    filenames.delete('.')
    filenames.delete('..')
    filenames.delete('archive')
    filenames
  end

end