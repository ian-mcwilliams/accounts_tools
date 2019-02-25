require 'rxl'
require_relative '../../config'

module BooksIngress
  CONFIG = Config.get_config

  def self.import_books
    filepaths_hash = {
      contracts: CONFIG['contracts_filepath'],
      sales_and_vat: CONFIG['sales_and_vat_filepath']
    }
    Rxl.read_files(filepaths_hash, :as_tables)
  end

end
