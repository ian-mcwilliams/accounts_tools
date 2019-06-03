[<< documentation list](../../README.md)

# Convert Bank Extract

This tool is designed to take a downloaded csv from Barclays containing account entries as an input, on running the process the existing bank book will be archived and the new one with added entries will be saved.

## Before running this tool

### Download the PDF and CSV

1. Log in to Barclays and go to the view statements page (in Quick Links)
2. Identify the new statement row and click the pdf icon (opens in a new tab)
3. Download the PDF as follows:
   * Click the print icon in the top right hand corner of the new tab (in the menu that appears when you move the cursor around the page)
   * If the destination is not "Save as PDF" use the Change button to set it to that value
   * Click Save and select the location as `accounts_tools/source_files` (in dev folder)
4. Download the CSV as follows:
   * Close the E-Statement tab and click the "View transactions" link next to the PDF icon you originally clicked
   * Click the "Export All" link at the top of the list of transactions and select "Spreadsheet eg Excel" from the list
   * If the downloaded csv file was not saved to `accounts_tools/source_files` then move it there, and ensure it is named `data.csv`

## Running this tool
**IN TERMINAL:** `ruby run_tool.rb convert_bank_extract`

### Results

The current bank book is archived with a timestamp filename to:

`bookkeeping/archive/bank_book`

The data.csv records are reformatted to become new rows in the new bank book with the period derived from the transaction dates, and the updated book is saved as:

`bookkeeping/bank.xlsx` 

The data.csv file is archived with the same timestamp to:

`bookkeeping/archive/data_csv`

The bank statement is renamed using the first and last transaction dates from the csv and saved to:

`bookkeeping/records/bank_statements`
