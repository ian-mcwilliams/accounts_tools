# THE PURPOSE OF THIS EXERCISE IS TO REPLICATE THE EXCEL BASED METHOD OF CATEGORISING DR/CR ENTRIES FROM MONTHLY BANK STATEMENT DOWNLOADS.
# Read bank statement (data.csv) and assign code_of_account identity to each Dr or Cr and output to coded.csv

require 'csv'

csv_text = File.read('data.csv')
csv = CSV.parse(csv_text, :headers => true)
csv.each do |row|
  puts "Enter Code of Account:            ? or help for valid code"
  puts ""
  puts row
  puts ""
  loop do
    code_of_account = gets.chomp.downcase
    if ['ap', 'ar', 'b', 'c', 'ch', 'ct', 'f', 'o', 'p', 's', 't', 'tni', 'v', 'w', '?'].include? code_of_account
    begin
      separator = ''
      File.open("coded_2.csv", "a+") {|f|
        f.write(code_of_account)
        f.write(row)
        f.write(separator)
      }
    break
    end
    else
    puts ""
    puts "*************************************"
    puts "***INVALID CODE... PLEASE RE-ENTER***"
    puts "*************************************"
    puts ""
    puts "Enter valid code:"
    puts ""
    puts "(AP: Acc_P)    (AR: Acc_R)      (B: Bank)          (C: Comms)        (CT: C_Tax)"
    puts ""
    puts "(CH: Co_Hse)   (F:  Fines)      (O: Office_Costs)  (P: Salary)       (S: Sundry)"
    puts ""
    puts "(T: Transport) (TNI: Tax & NI)  (V: VAT)           (W: Withdrawal)"
    end
  end
end



