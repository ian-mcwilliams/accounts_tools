def oph(output_str)
  wrapped_str = inset_str("   #{output_str}   ", '=', 100)
  puts '===================================================================================================='
  puts wrapped_str
  puts '===================================================================================================='
end

def inset_str(str, wrapper, length)
  return_str = "#{str}"
  until return_str.length >= length
    return_str.prepend(wrapper)
    return_str << wrapper unless return_str.length == length
  end
  return_str
end

def await_return
  print('=============== press return to continue ===============')
  gets
end

def output_accounts_summary(accounting_period)
  require_relative 'run_reports/accounts_summary'

  def add_column(str, text, str_length)
    str += text.to_s
    str += ' ' until str.length >= str_length
    str
  end

  accounts_summary = AccountsSummary.new(accounting_period)

  account_strings = []
  accounts_summary.accounts.each do |account|
    account_string = ''
    account_string = add_column(account_string, account.code, 5)
    account_string = add_column(account_string, account.name, 30)
    account_string = add_column(account_string, account.balance.upcase, 35)
    account_string = add_column(account_string, account.dr_value, 45)
    account_string = add_column(account_string, account.cr_value, 55)
    account_string = add_column(account_string, account.value, 65)
    account_string = add_column(account_string, account.adj_value, 75)
    account_strings << account_string
  end

  puts 'CODE ACCOUNT                  BAL  DR        CR        VALUE     ADJ_VALUE'
  puts '---------------------------------------------------------------------------'

  account_strings.each do |str|
    puts str
  end

  puts ''

  puts "ASSETS:               #{accounts_summary.assets_value}"
  puts "LIABILITIES + EQUITY: #{accounts_summary.liabilities_plus_equity_value}"
  puts "ACCOUNTS BALANCE:     #{accounts_summary.accounts_balance}"
end