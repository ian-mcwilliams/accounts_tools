require 'csv'
require 'axlsx'

module ConvertBankExtract

  def self.load_file
    source = ENV['convert_bank_extract_file_source']
    file = CSV.open(source).map { |row| row }
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

  def self.new_excel_file
    file = Axlsx::Package.new
    workbook = file.workbook
    workbook.add_worksheet(name: 'output')
    file
  end

end