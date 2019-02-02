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
#
#       *** !!!   ALWAYS REMEMBER   !!! ***      *** !!!   ALWAYS REMEMBER   !!! ***
#
# first download the bank statement and save it in records/bank_statements
# the statement filename is based on the OPENING and CLOSING transactions dates on the statement
# when you download from Barclays the extract MUST BE BASED ON A SEARCH FOR THE SAME TWO DATES
#
#       *** !!!   ALWAYS REMEMBER   !!! ***      *** !!!   ALWAYS REMEMBER   !!! ***
#
#
# TO RUN:
#  - save the target file to the source_file directory as data.csv (this is the default filename but watch out for
#      duplicate naming avoidance like "data (1).csv")
#  - ensure the sheet's tab name is "data" (this is the current default so no change should be needed)
#  - IN TERMINAL: ruby run_tool.rb convert_bank_extract
#  - find the result in the run_results/convert_bank_extract directory (old results are overwritten)
#  - copy and paste the row VALUES ONLY into the bank.xlsx spreadsheet (NOTE: the empty column D is there... honest!)
#  - copy/drag down the balance column and id column and add the statement filename and period id
#  - verify that the balance on the last row matches the balance on the final transaction on the bank statement

if target == 'convert_bank_extract'
  require_relative 'convert_bank_extract/lib/convert_bank_extract'
  ConvertBankExtract.convert_bank_extract
end



