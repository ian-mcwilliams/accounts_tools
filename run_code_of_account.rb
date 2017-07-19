require_relative 'code_of_account/code_of_account'

output_excel = false
exclusions = false
accounting_month = nil

ARGV.each_with_index do|arg, index|
  accounting_month = arg.to_i if index == 0
  output_excel = (arg == 'true') if index == 1
  exclusions = arg if index == 2
end

if accounting_month
  CodeOfAccount.new(accounting_month, output_excel, exclusions)
else
  puts 'You must provide an accounting month [eg. ruby run_code_of_account "1"]'
end