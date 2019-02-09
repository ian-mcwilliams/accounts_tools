require 'csv'
require 'yaml'

module ConvertBankExtract

  def self.convert_bank_extract
    file = load_file
    hashes = build_hashes(file)
    create_excel_file(sorted_hashes(hashes))
  end

  def self.load_file
    file = CSV.open(ENV['CONVERT_BANK_EXTRACT_SOURCE_FILEPATH']).map { |row| row }
    file.shift
    file
  end

  def self.build_hashes(arrays)
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

  def self.sorted_hashes(hashes)
    hashes.sort_by { |item| item[:date] }
  end

  def self.create_excel_file(hashes)
    order = %i[date debit credit blank_col subcat description]
    output = hashes_to_rxl_worksheet(hashes, order, write_headers: false)
    Rxl.write_file(ENV['CONVERT_BANK_EXTRACT_SAVE_FILEPATH'], { 'output' => output })
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