require_relative 'env'
args = ARGV.map { |arg| arg }
target = args.shift

# THIS FILE SHOULD EVENTUALLY CONTAIN ALL ACCOUNTS TOOLS CALLS AND INFO ON HOW TO RUN EACH

# The call to this file takes an argument specifying what task to run, see the documentation for the relevant task for
# details of how to make a valid call

module RunTool

  def self.run_tool(target, _)
    store_target = ENV['ACCOUNT_TOOL']
    ENV['ACCOUNT_TOOL'] = target

    case ENV['ACCOUNT_TOOL']

    when 'convert_bank_extract'
      require_relative 'apps/convert_bank_extract/lib/convert_bank_extract'
      ConvertBankExtract.convert_bank_extract

    when 'manage_office_space_costs'
      require_relative 'apps/manage_office_space_costs/lib/manage_office_space_costs'
      ManageOfficeSpaceCosts.manage_office_space_costs

    when 'reconcile_sales'
      require_relative 'apps/reconcile_contracts_and_sales/lib/books_ingress'
      BooksIngress.import_books

    else
      raise("no tool found for target: '#{target}'")
    end

    ENV['ACCOUNT_TOOL'] = store_target if store_target
  end

end

RunTool.run_tool(target, args)
