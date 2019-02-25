[<< documentation list](../../README.md)

# Convert Bank Extract

This tool is designed to take a downloaded csv from Barclays containing account entries as an input, and it will
output a console which can be copied directly to the bank.xlsx bookkeeping file.

The end to end process is described here.

## Before running this tool

NB For a cleaner way to complete step 3, go to the 'view statements' section of the Barclays site, same place as to download the PDF - in the relevant row, the 'view transactions' link opens the transactions for the relevant period which can then be exported as usual

1. download the PDF bank statement and save it in records/bank_statements
2. the PDF statement filename is based on the **opening and closing transaction dates** on the statement (the first and last transaction in the list of transactions, not the opening and closing balance )
3. when you then download the CSV from Barclays the extract **MUST** match the opening and closing transaction dates from the PDF statement
4. save the CSV file to the accounts_tools/source_file directory as data.csv (*this is the default filename but watch out for duplicate naming avoidance like "data (1).csv"*)
5. ensure the sheet's tab name is "data" (*this is the current default so no change should be needed*)

## Running this tool
**IN TERMINAL:** `ruby run_tool.rb convert_bank_extract`

## After running this tool

1. Verify that the balance on the last row matches the balance on the final transaction on the bank statement to confirm success
2. Confirm that the previous version of bank.xlsx is found in bookkeeping/archive named with a timestamped suffix (eg bank_archive_190101180000.xlsx)
