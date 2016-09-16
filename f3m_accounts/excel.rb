require 'simple_xlsx_reader'

class Excel
  attr_accessor :file_contents

  def import_file_contents(file_path)
    @file_contents = SimpleXlsxReader.open(file_path)
  end
end