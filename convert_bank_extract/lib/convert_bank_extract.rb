require 'csv'
require 'rxl'
require 'yaml'
require_relative '../../config'

module ConvertBankExtract
  CONFIG = Config.get_config

  def self.convert_bank_extract
    bank_book = load_file(:bank_book)
    extract = load_file(:csv)
    first_id = bank_book[-1]['id'].to_i + 1
    period = next_period_string(bank_book[-1]['period'])
    opening_balance = bank_book[-1]['balance']
    hashes = build_hashes(extract, first_id, period, opening_balance)
    filepath = CONFIG['bank_book_filepath']
    archive_filename = "bank_archive_#{DateTime.now.strftime('%y%m%d%H%M%S')}.xlsx"
    archive_current_bank_book(archive_filename)
    create_excel_file(filepath, hashes)
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
    hashes.sort_by! { |hash| DateTime.parse(hash[:date]) }
    opening_date = DateTime.parse(hashes[0][:date]).strftime('%y%m%d')
    closing_date = DateTime.parse(hashes[-1][:date]).strftime('%y%m%d')
    statement = "08046_#{opening_date}-#{closing_date}"
    current_balance = opening_balance.to_s
    hashes.each_with_index do |hash, i|
      hash[:id] = (first_id.to_i + i).to_s
      hash[:period] = period
      hash[:statement] = statement
      current_balance = new_balance(current_balance, hash[:debit], hash[:credit])
      hash[:balance] = current_balance.dup
    end
  end

  def self.new_balance(current, debit, credit)
    current_pence = current.to_s.delete('.').to_i
    debit_pence = debit.to_s.delete('.').to_i
    credit_pence = credit.to_s.delete('.').to_i
    new_pence = (current_pence - debit_pence + credit_pence).to_s
    "#{new_pence[0..-3]}.#{new_pence[-2..-1]}"
  end

  def self.build_initial_hashes(arrays)
    arrays.map do |array|
      {
        date: array[1],
        debit: array[3][0] == '-' ? array[3].gsub('-', '') : nil,
        credit: array[3][0] == '-' ? nil : array[3].gsub('-', ''),
        subcat: array[4],
        description: array[5]
      }
    end
  end

  def self.archive_current_bank_book(archive_filename)
    bookkeeping_path = CONFIG['bookkeeping_path']
    bookkeeping_archive_path = CONFIG['bookkeeping_archive_path']
    archive_bank_book_filepath = "#{bookkeeping_archive_path}#{archive_filename}"
    File.rename("#{bookkeeping_path}bank.xlsx", "#{bookkeeping_path}#{archive_filename}")
    FileUtils.mv("#{bookkeeping_path}#{archive_filename}", archive_bank_book_filepath)
  end

  def self.create_excel_file(filepath, hashes)
    order = %i[id period statement date debit credit balance subcat description]
    Rxl.write_file_as_tables(filepath, { 'bank' => hashes }, order)
  end

  def self.hashes_to_rxl_worksheet(hashes, order, write_headers: true)
    rows = hashes.map do |hash|
      order.map { |item| hash[item] }
    end
    rows.unshift(order.map { |item| "#{item}" }) if write_headers
    rows_to_rxl_worksheet(rows)
  end

  def self.rows_to_rxl_worksheet(rows)
    rxl_worksheet = {}
    rows.count.times do |i|
      rows[i].each_with_index do |cell_value, index|
        rxl_worksheet["#{column_name(index)}#{i + 1}"] = { value: cell_value }
      end
    end
    rxl_worksheet
  end

  def self.column_name(int)
    name = 'A'
    int.times { name.succ! }
    name
  end

end