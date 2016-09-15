o# THE PURPOSE OF THIS EXERCISE IS TO REPLICATE THE EXCEL BASED METHOD OF CATEGORISING DR/CR ENTRIES FROM MONTHLY BANK STATEMENT DOWNLOADS.
# Read bank statement (data.csv) and assign code_of_account identity to each Dr or Cr and output to coded.csv

require 'csv'

csv_text = File.read('data.csv')
csv = CSV.parse(csv_text, :headers => true)
csv.each do |row|
  puts 'Enter Code of Account:            ? or help for valid code'
  puts ''
  puts row
  puts ''
  loop do # Loops current row while code_of_account inputs are invalid
    code_of_account = gets.chomp.downcase
    if ['ap', 'ar', 'b', 'c', 'ch', 'ct', 'f', 'o', 'p', 's', 't', 'tni', 'v', 'w', '?'].include? code_of_account
      begin
        account = code_of_account
        case account
          when 'ap'
            ap = 'Acc_P'
            code_of_account = ap
          when 'ar'
            ar = 'Acc_R'
            code_of_account = ar
          when 'b'
            b = 'Bank'
            code_of_account = b
          when 'c'
            c = 'Comms'
            code_of_account = c
          when 'ct'
            ct = 'C_Tax'
            code_of_account = ct
          when 'ch'
            ch = 'Co_Hse'
            code_of_account = ch
          when 'f'
            f = 'Fines'
            code_of_account = f
          when 'o'
            o = 'Office_Costs'
            code_of_account = o
          when 'p'
            p = 'Salary'
            code_of_account = p
          when 's'
            s = 'Sundry'
            code_of_account = s
          when 't'
            t = 'Transport'
            code_of_account = t
          when 'tni'
            tni = 'Tax_NI'
            code_of_account = tni
          when 'v'
            v = 'VAT'
            code_of_account = v
          when 'w'
            w = 'Withdrawal'
            code_of_account = w
        end
        puts ''
        separator = ''
        File.open('coded_1.csv', 'a+') {|f|
          f.write(code_of_account)
          f.write(row)
          f.write(separator)
        }
        break
      end
    else
      puts ''
      puts '*************************************'
      puts '***INVALID CODE... PLEASE RE-ENTER***'
      puts '*************************************'
      puts ''
      puts 'Enter valid code:'
      puts ''
      puts '(AP: Acc_P)    (AR: Acc_R)      (B: Bank)          (C: Comms)        (CT: C_Tax)'
      puts ''
      puts '(CH: Co_Hse)   (F:  Fines)      (O: Office_Costs)  (P: Salary)       (S: Sundry)'
      puts ''
      puts '(T: Transport) (TNI: Tax & NI)  (V: VAT)           (W: Withdrawal)'
      puts ''
    end
  end
end