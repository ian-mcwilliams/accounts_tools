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
    bookkeeping_path = CONFIG['bookkeeping_path']
    archive_path = CONFIG['bookkeeping_archive_path']
    filepaths = dir_filenames(bookkeeping_path).map { |item| "#{bookkeeping_path}#{item}" }
    filepaths.concat(dir_filenames(archive_path).map { |item| "#{archive_path}#{item}" })
    filepaths.each { |filepath| File.delete(filepath) }
    bank_source = 'apps/convert_bank_extract/spec/support/test_files/bank.xlsx'
    FileUtils.cp(bank_source, CONFIG['bookkeeping_path']) if state == :setup
  end

  def self.dir_filenames(path)
    filenames = Dir.entries(path)
    filenames.delete('.')
    filenames.delete('..')
    filenames.delete('archive')
    filenames
  end

end