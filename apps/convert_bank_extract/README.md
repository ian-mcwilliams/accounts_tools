[<< documentation list](../../README.md)

# Convert Bank Extract

This tool is designed to take a downloaded csv from Barclays containing account entries as an input, on running the process the existing bank book will be archived and the new one with added entries will be saved.

## Before running this tool

### Download the PDF and CSV

1. download the PDF bank statement from barclays
2. go to the 'view statements' section of the Barclays site, same place as to download the PDF - in the relevant row, the 'view transactions' link opens the transactions for the relevant period which can then be exported as usual
- NB when you download the CSV from Barclays the extract **MUST** match the opening and closing transaction dates from the PDF statement

### Save the PDF in Dropbox

- save to LiveCorp/records/bank_statements
- the PDF statement filename is based on the **opening and closing transaction dates** on the statement (the first and last transaction in the list of transactions, not the opening and closing balance )

### Save the CSV in dev/accounts_tools

- save the CSV file to the dev/accounts_tools/source_file directory as data.csv (*this is the default filename but watch out for duplicate naming avoidance like "data (1).csv"*)
- ensure the sheet's tab name is "data" (*this is the current default so no change should be needed*)

## Running this tool
**IN TERMINAL:** `ruby run_tool.rb convert_bank_extract`

## After running this tool

1. Verify that the balance on the last row matches the balance on the final transaction on the bank statement to confirm success
2. Confirm that the previous version of bank.xlsx is found in bookkeeping/archive named with a timestamped suffix (eg bank_archive_190101180000.xlsx)
