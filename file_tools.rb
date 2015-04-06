require 'simple_xlsx_reader'

class FileTools

  attr_accessor(:contents)

  def initialize(filepath, key=nil)
    puts "hostname = #{Socket.gethostname}"
    filepath = "#{get_filepath(key)}#{filepath}" if key
    @contents = get_file_contents(filepath)
  end

  def machine_keys
    {
        ian:  	['F3M3s-MacBook-Air.local', 'f3m3s-air.home'],
        ian_w:  ['OE2021.local'],
        dad: 	  ['John']
    }
  end

  def get_machine_key
    machine_keys.each { |key, value| return key if value.include?(Socket.gethostname) }
  end

  def get_rel_path
    {
        ian: 	  '../../../../Applications/MAMP/bin/mamp/Dropbox/',
        ian_w:  '../../../ian/accounts/',
        dad: 	  '../../Users/John/Dropbox/'
    }[get_machine_key]
  end

  def get_file_contents(filepath)
    SimpleXlsxReader.open("#{get_rel_path}#{filepath}")
  end

  def get_filepath(key)
    {
        accounts: "F3Mmedia/Internal/ACcounts/___YEAR_END_FINAL_ACCOUNTS/"
    }[key]
  end

end