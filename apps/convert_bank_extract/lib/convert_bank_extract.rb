require 'csv'
require 'rxl'
require 'yaml'
require_relative '../../../config'

module ConvertBankExtract
  CONFIG = Config.get_config

  def self.convert_bank_extract
    verify_file_presence
    filepath = CONFIG['bank_book_filepath']
    write_hash = build_write_hash
    archive_filename = "bank_archive_#{DateTime.now.strftime('%y%m%d%H%M%S')}.xlsx"
    archive_current_bank_book(archive_filename)
    create_excel_file(filepath, write_hash)
    delete_source_file
  end

  def self.verify_file_presence
    unless File.exists?(CONFIG['bank_book_filepath'])
      raise("bank book not found at path: #{CONFIG['bank_book_filepath']}")
    end
    unless File.exists?(CONFIG['bank_extract_filepath'])
      raise("bank extract csv not found at path: #{CONFIG['bank_extract_filepath']}")
    end
    unless File.exists?(CONFIG['bank_statement_filepath'])
      raise("bank statement pdf not found at path: #{CONFIG['bank_statement_filepath']}")
    end
  end

  def self.build_write_hash
    bank_book = load_file(:bank_book)
    extract = load_file(:csv)
    first_id = bank_book[-1]['id'].to_i + 1
    period = next_period_string(bank_book[-1]['period'])
    opening_balance = bank_book[-1]['balance']
    hashes = build_hashes(extract, first_id, period, opening_balance)
    { 'bank' => bank_book + hashes, formats: formats_hash }
  end

  def self.load_file(file_key)
    case file_key
    when :csv
      file = CSV.open(CONFIG['bank_extract_filepath']).map { |row| row }
      file.shift
      file
    when :bank_book
      Rxl.read_file_as_tables(CONFIG['bank_book_filepath'])['bank']
    else
      raise("file_key '#{file_key}' not recognised")
    end
  end

  def self.next_period_string(current)
    year, month = current.split('-')
    month == '12' ? "#{year.to_i + 1}-1" : "#{year}-#{month.to_i + 1}"
  end

  def self.build_hashes(arrays, first_id, period, opening_balance)
    hashes = build_initial_hashes(arrays)
    hashes.sort_by! { |hash| DateTime.parse(hash['date']) }
    opening_date = DateTime.parse(hashes[0]['date']).strftime('%y%m%d')
    closing_date = DateTime.parse(hashes[-1]['date']).strftime('%y%m%d')
    statement = "08046_#{opening_date}-#{closing_date}"
    current_balance = opening_balance.to_s
    hashes.each_with_index do |hash, i|
      hash['id'] = (first_id.to_i + i)
      hash['period'] = period
      hash['statement'] = statement
      hash['date'] = DateTime.parse(hash['date'])
      current_balance = new_balance(current_balance, hash['debit'], hash['credit'])
      hash['balance'] = current_balance.to_f
      hash['debit'] = hash['debit'].to_f
      hash['credit'] = hash['credit'].to_f
    end
  end

  def self.new_balance(current, debit, credit)
    current_pence = current.to_s.delete('.').to_i
    debit_pence = debit.to_s.delete('.').to_i
    credit_pence = credit.to_s.delete('.').to_i
    new_pence = (current_pence - debit_pence + credit_pence).to_s
    "#{new_pence[0..-3]}.#{new_pence[-2..-1]}"
  end

  def self.bank_statement_filename(hashes)
    sorted_dates = hashes.map { |h| h['date'] }.sort
    opening_date_string = sorted_dates[0].strftime('%y%m%d')
    closing_date_string = sorted_dates[-1].strftime('%y%m%d')
    "#{CONFIG['bank_prefix']}_#{opening_date_string}-#{closing_date_string}.pdf"
  end

  def self.build_initial_hashes(arrays)
    arrays.map do |array|
      {
        'date' => array[1],
        'debit' => array[3][0] == '-' ? array[3].gsub('-', '') : nil,
        'credit' => array[3][0] == '-' ? nil : array[3].gsub('-', ''),
        'subcat' => array[4],
        'description' => array[5]
      }
    end
  end

  def self.formats_hash
    {
      'bank' => {
        headers: {
          bold: true,
          h_align: 'center',
          fill: '999999'
        },
        'A' => { format: :number },
        'D' => { format: :date },
        'E' => { format: :number, decimals: 2 },
        'F' => { format: :number, decimals: 2 },
        'G' => { format: :number, decimals: 2 },
      }
    }
  end

  def self.archive_current_bank_book(archive_filename)
    bookkeeping_path = CONFIG['bookkeeping_path']
    bookkeeping_archive_path = CONFIG['bookkeeping_archive_path']
    archive_bank_book_filepath = "#{bookkeeping_archive_path}#{archive_filename}"
    FileUtils.mkdir_p(bookkeeping_archive_path)
    File.rename("#{bookkeeping_path}bank.xlsx", "#{bookkeeping_path}#{archive_filename}")
    FileUtils.mv("#{bookkeeping_path}#{archive_filename}", archive_bank_book_filepath)
  end

  def self.create_excel_file(filepath, write_hash)
    order = %w[id period statement date debit credit balance subcat description]
    Rxl.write_file_as_tables(filepath, write_hash, order)
  end

  def self.archive_bank_statement(archive_filename)
    FileUtils.mv(CONFIG['bank_statement_filepath'], CONFIG['bank_statements_path'])
    old_filepath = "#{CONFIG['bank_statements_path']}#{CONFIG['bank_statement_filename']}"
    new_filepath = "#{CONFIG['bank_statements_path']}#{archive_filename}"
    File.rename(old_filepath, new_filepath)
  end

  def self.delete_source_file
    FileUtils.rm(CONFIG['bank_extract_filepath'])
  end

end