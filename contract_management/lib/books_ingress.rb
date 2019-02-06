require 'rxl'

module BooksIngress

  def self.import_books
    filepaths_hash = {
      contracts: ENV['CONTRACTS_FILEPATH'],
      sales_and_vat: ENV['SALES_AND_VAT_FILEPATH']
    }
    Rxl.read_files(filepaths_hash, :as_tables)
  end

end
