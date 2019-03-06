require 'colorize'
require 'csv'
require 'rxl'
require 'yaml'
require_relative '../../../config'

module ConvertBankExtract
  CONFIG = Config.get_config

  def self.convert_bank_extract
    print "converting bank extract\n"
    timestamp = DateTime.now.strftime('%y%m%d%H%M%S')
    print "verifying required files present... #{"checking".red}\r"
    verify_file_presence
    print "verifying required files present... #{"done".green}    \n"
    filepath = CONFIG['bank_book_filepath']
    print "loading bank book...                #{"loading".red}\r"
    bank_book = load_file(:bank_book)
    print "loading bank book...                #{"done".green}   \n"
    print "loading data.csv...                 #{"loading".red}\r"
    hashes = csv_hashes(bank_book)
    print "loading data.csv...                 #{"done".green}   \n"
    period_string = generate_period_string(hashes)
    archive_bank_book_filename = "bank_archive_#{period_string}_#{timestamp}.xlsx"
    print "archiving current bank book...      #{"archiving".red}\r"
    archive_current_bank_book(archive_bank_book_filename)
    print "archiving current bank book...      #{"done".green} (saved as #{archive_bank_book_filename})\n"
    print "creating updated bank book...       #{"building".red}\r"
    write_hashes = build_write_hash(bank_book, hashes)
    create_excel_file(filepath, write_hashes)
    print "creating updated bank book...       #{"done".green}    \n"
    bank_statement_filename = "#{CONFIG['bank_prefix']}_#{period_string}.pdf"
    print "storing bank statement...           #{"storing".red}\r"
    archive_bank_statement(bank_statement_filename)
    print "storing bank statement...           #{"done".green} (saved as #{bank_statement_filename})\n"
    data_csv_filename = "data_csv_archive_#{period_string}_#{timestamp}.csv"
    print "archiving data.csv...               #{"archiving".red}\r"
    archive_data_csv_file(data_csv_filename)
    print "archiving data.csv...               #{"done".green} (saved as #{data_csv_filename})\n"
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

  def self.csv_hashes(bank_book)
    extract = load_file(:csv)
    first_id = bank_book[-1]['id'].to_i + 1
    opening_balance = bank_book[-1]['balance']
    build_hashes(extract, first_id, opening_balance)
  end

  def self.build_write_hash(bank_book, hashes)
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

  def self.build_hashes(arrays, first_id, opening_balance)
    hashes = build_initial_hashes(arrays)
    hashes.sort_by! { |hash| DateTime.parse(hash['date']) }
    opening_date = DateTime.parse(hashes[0]['date']).strftime('%y%m%d')
    closing_date = DateTime.parse(hashes[-1]['date']).strftime('%y%m%d')
    statement = "08046_#{opening_date}-#{closing_date}"
    current_balance = opening_balance.to_s
    hashes.each_with_index do |h, i|
      apply_dynamic_hash_values(h, i, first_id, statement, current_balance)
    end
  end

  def self.apply_dynamic_hash_values(h, i, first_id, statement, current_balance)
    h['id'] = (first_id.to_i + i)
    h['period'] = period_string(h['date'])
    h['statement'] = statement
    h['date'] = DateTime.parse(h['date'])
    current_balance = new_balance(current_balance, h['debit'], h['credit'])
    h['balance'] = current_balance.to_f
    h['debit'] = h['debit'].to_f unless h['debit'].nil?
    h['credit'] = h['credit'].to_f unless h['credit'].nil?
  end

  def self.period_string(date)
    _, month, year = date.split('/')
    if year == '2010'
      "1-#{month.to_i - 8}"
    elsif year == '2011' && month.to_i < 9
      "1-#{month.to_i + 4}"
    elsif year == '2011' && %w[09 10].include?(month)
      "2-#{month.to_i - 8}"
    elsif month.to_i > 10
      "#{year.to_i - 2008}-#{month.to_i - 10}"
    else
      "#{year.to_i - 2009}-#{month.to_i + 2}"
    end
  end

  def self.new_balance(current, debit, credit)
    current_pence = current.to_s.delete('.').to_i
    debit_pence = debit.to_s.delete('.').to_i
    credit_pence = credit.to_s.delete('.').to_i
    new_pence = (current_pence - debit_pence + credit_pence).to_s
    "#{new_pence[0..-3]}.#{new_pence[-2..-1]}"
  end

  def self.generate_period_string(hashes)
    sorted_dates = hashes.map { |h| h['date'] }.sort
    opening_date_string = sorted_dates[0].strftime('%y%m%d')
    closing_date_string = sorted_dates[-1].strftime('%y%m%d')
    "#{opening_date_string}-#{closing_date_string}"
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
    bank_book_archive_path = CONFIG['bank_book_archive_path']
    archive_bank_book_filepath = "#{bank_book_archive_path}#{archive_filename}"
    FileUtils.mkdir_p(bank_book_archive_path)
    File.rename("#{bookkeeping_path}bank.xlsx", "#{bookkeeping_path}#{archive_filename}")
    FileUtils.mv("#{bookkeeping_path}#{archive_filename}", archive_bank_book_filepath)
  end

  def self.create_excel_file(filepath, write_hash)
    order = %w[id period statement date debit credit balance subcat description]
    Rxl.write_file_as_tables(filepath, write_hash, order)
  end

  def self.archive_bank_statement(archive_filename)
    bank_statements_path = CONFIG['bank_statements_path']
    FileUtils.mkdir_p(bank_statements_path)
    FileUtils.mv(CONFIG['bank_statement_filepath'], bank_statements_path)
    old_filepath = "#{CONFIG['bank_statements_path']}#{CONFIG['bank_statement_filename']}"
    new_filepath = "#{CONFIG['bank_statements_path']}#{archive_filename}"
    File.rename(old_filepath, new_filepath)
  end

  def self.archive_data_csv_file(archive_filename)
    data_csv_archive_path = CONFIG['data_csv_archive_path']
    FileUtils.mkdir_p(data_csv_archive_path)
    FileUtils.mv(CONFIG['bank_extract_filepath'], "#{data_csv_archive_path}#{archive_filename}")
  end

end