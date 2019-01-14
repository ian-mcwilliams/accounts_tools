# THIS FILE SHOULD EVENTUALLY CONTAIN ALL ACCOUNTS TOOLS CALLS AND INFO ON HOW TO RUN EACH

# The call to this file takes an argument specifying what task to run, see the documentation for the relevant task for
# details of how to make a valid call

target = nil
args = []

ARGV.each_with_index { |arg, index| index == 0 ? target = arg : args << arg }

# CONVERT BANK STATEMENT
#
# This tool is designed to take a downloaded csv from Barclays containing account entries as an input, and it will
# output a console which can be copied directly to the bank.xlsx bookkeeping file
#
# TO RUN:
# - save the target file to the source_file directory as convert_bank_extract.xlsx
# - ensure the sheet's tab name is "data" (this is the current default so no change should be needed)
# - ruby run_tool.rb convert_bank_extract

if target == 'convert_bank_extract'
  require_relative 'convert_bank_extract/convert_bank_extract'
  ConvertBankStatement.execute
end



