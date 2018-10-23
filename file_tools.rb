require 'simple_xlsx_reader'
require 'axlsx'
require 'socket'

class FileTools

  attr_accessor(:contents)

  def initialize(accounting_period, file_type, key=nil)
    filepath = get_filepaths(file_type)[accounting_period - 1]
    puts "hostname = #{Socket.gethostname}"
    filepath = "#{get_filepath(key)}#{filepath}" if key
    @contents = get_file_contents(filepath)
  end

  # on mac, type hostname in terminal
  def self.machine_keys
    {
        ian:  	%w[F3M3s-MacBook-Air.local f3m3s-air.home f3m3s-air F3M3sMA.local f3m3sma F3M3sMA.home],
        ian_w:  ['OE2021.local'],
        dad: 	  ['John'],
        john:   ['Johns-Mac-mini.home']
    }
  end

  def self.get_machine_key
    FileTools.machine_keys.each { |key, value| return key if value.include?(Socket.gethostname) }
  end

  def self.get_rel_path
    {
        ian: 	  '../../Dropbox/',
        ian_w:  '../../../ian/accounts/',
        dad: 	  '../../Users/John/Dropbox/',
        john:   '../../Dropbox/'
    }[FileTools.get_machine_key]
  end

  def get_file_contents(filepath)
    SimpleXlsxReader.open("#{FileTools.get_rel_path}#{filepath}")
  end

  def get_filepath(key)
    {
        accounts: 'F3Mmedia/Internal/ACcounts/'
    }[key]
  end

  def self.write_output_to_excel(file_name, output_sheets)
    Axlsx::Package.new do |p|
      output_sheets.each do |output_sheet|
        p.workbook.add_worksheet(name: output_sheet[:sheet_name]) do |sheet|
          forced_float_format = sheet.styles.add_style :format_code => '0.00'
          output_sheet[:output].each { |row| sheet.add_row(row, :style => [nil, nil, nil, forced_float_format, forced_float_format, forced_float_format]) }
        end
      end
      p.serialize(file_name)
    end
  end

  def get_filepaths(file)
    filepaths = []
    %w[
        LiveCorp/1.1009-1108
        LiveCorp/2.1109-1110
        LiveCorp/3.1111-1210
        LiveCorp/4.1211-1310
        LiveCorp/5.1311-1410
        LiveCorp/6.1411-1510
        LiveCorp/7.1511-1610
        LiveCorp/8.1611-1710
    ].each_with_index do |filepath, index|
      filepaths << "#{filepath}/#{accounts_filenames[index]}" if file == :accounts
      filepaths << "#{filepath}/Reports#{index + 1}.xlsx" if file == :reports
      filepaths << "#{filepath}/Exclusions.xlsx" if file == :results
    end
    filepaths
  end

  def accounts_filenames
    %w[
				Accounts1.xlsx
				Accounts2.xlsx
				Accounts3.xlsx
				Accounts4.xlsx
				Accounts5.xlsx
        Accounts6.xlsx
        Accounts7.xlsx
        Accounts8.xlsx
		]
  end

end