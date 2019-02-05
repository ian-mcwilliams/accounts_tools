[<< documentation list](../README.md)

# Convert Bank Extract

This tool is designed to take a downloaded csv from Barclays containing account entries as an input, and it will
output a console which can be copied directly to the bank.xlsx bookkeeping file.

The end to end process is described here.

## Before running this tool

1. download the bank statement and save it in records/bank_statements
2. the statement filename is based on the **opening and closing transaction dates** on the statement
3. when you download from Barclays the extract **MUST** match the opening and closing transaction dates from the statement
4. save the target file to the source_file directory as data.csv (*this is the default filename but watch out for duplicate naming avoidance like "data (1).csv"*)
5. ensure the sheet's tab name is "data" (*this is the current default so no change should be needed*)

## Running this tool
**IN TERMINAL:** `ruby run_tool.rb convert_bank_extract`

## After running this tool
1. find the result in the `run_results/convert_bank_extract` directory (*NB old results are overwritten*)
2. copy the row and paste **(VALUES ONLY)** into the bank.xlsx spreadsheet (*NB the empty column D is there... honest! just paste as is*)
3. copy/drag down the balance column and id column and add the statement filename and period id

**FINALLY:** Verify that the balance on the last row matches the balance on the final transaction on the bank statement to confirm success
