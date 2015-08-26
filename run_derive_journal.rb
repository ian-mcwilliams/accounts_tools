require_relative 'derive_journal/derive_journal'

output_excel = false
exclusions = false
accounting_period = nil

ARGV.each_with_index do|arg, index|
  accounting_period = arg.to_i if index == 0
  output_excel = (arg == 'true') if index == 1
  exclusions = arg if index == 2
end

if accounting_period
  DeriveJournal.new(accounting_period, output_excel, exclusions)
else
  puts 'You must provide an accounting period [eg. "ruby run_derive_journal 5"]'
end