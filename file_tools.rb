require 'simple_xlsx_reader'

class FileTools

  attr_accessor(:contents)

  def initialize(filepath, key=nil)
    filepath = "#{get_filepath(key)}#{filepath}" if key
    @contents = get_file_contents(filepath)
  end

  def get_machine_name
    {
        ian: 	'F3M3s-MacBook-Air.local',
        dad: 	'John'
    }
  end

  def get_rel_path
    {
        ian: 	'../../../../Applications/MAMP/bin/mamp/Dropbox/',
        dad: 	''
    }[get_machine_name.key(Socket.gethostname)]
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