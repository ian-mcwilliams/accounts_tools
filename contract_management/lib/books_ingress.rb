require 'rxl'

module BooksIngress
  CONTRACTS_FILENAME = 'contracts.xlsx'
  SALES_AND_VAT_FILENAME = 'sales_and_vat.xlsx'

  def self.import_books
    rel_path = "contract_management/#{ENV['BOOKKEEPING_PATH']}"
    filepaths_hash = {
      contracts: "#{rel_path}#{CONTRACTS_FILENAME}",
      sales_and_vat: "#{rel_path}#{SALES_AND_VAT_FILENAME}"
    }
    Rxl.read_files(filepaths_hash, :as_tables)
  end
end
