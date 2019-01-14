require 'csv'
require 'axlsx'
require 'yaml'

module ConvertBankExtract

  def self.config
    all_config = YAML.load_file('convert_bank_extract/config.yml')
    ENV['test'] ? all_config['test'] : all_config['default']
  end

  def self.convert_bank_extract
    file = load_file
    hashes = build_hashes(file)
    create_excel_file(sorted_hashes(hashes))
  end

  def self.load_file
    source = config['source']
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

  def self.sorted_hashes(hashes)
    hashes.sort_by { |item| item[:date] }
  end

  def self.create_excel_file(hashes)
    file = Axlsx::Package.new
    workbook = file.workbook
    workbook.add_worksheet(name: 'output') do |sheet|
      hashes.each do |hash|
        row = [
          hash[:date],
          hash[:debit],
          hash[:credit],
          nil,
          hash[:subcat],
          hash[:description]
        ]
        sheet.add_row(row)
      end
    end
    file.serialize(config['save'])
  end

end