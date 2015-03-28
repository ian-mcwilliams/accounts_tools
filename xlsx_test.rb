require 'simple_xlsx_reader'
require 'socket'
require_relative 'account'

def get_machine_name
	{
		ian: 	'F3M3s-MacBook-Air.local',
		dad: 	'John'
	}
end

def get_rel_path
	{
		ian: 	'../../../../Applications/MAMP/bin/mamp/Dropbox/',
		dad: 	''
	}[get_machine_name.key(Socket.gethostname)]
end

def get_file_contents(filepath)
	SimpleXlsxReader.open("#{get_rel_path}#{filepath}")
end

def get_accounts_file(filepath)
	get_file_contents("F3Mmedia/Internal/ACcounts/___YEAR_END_FINAL_ACCOUNTS/#{filepath}")
end

doc = get_accounts_file('1. 1009-1108/AccountsAnalysis1011.xlsx')

doc.sheets.each_with_index do |sheet, index|
	print "#{sheet.name}\n"
	current_account = Account.new(sheet.rows)
end