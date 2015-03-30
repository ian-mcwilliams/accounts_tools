require 'socket'
require_relative 'account'
require_relative 'journal_entry'
require_relative 'journal_transaction'
require_relative 'file_tools'

def await_return
	print('=============== press return to continue ===============')
	gets
end

def revise_pattern_value(current_value, entry)
	{
			dr:	current_value - entry.dr,
			cr:	current_value + entry.cr
	}[entry.balance]
end

def pattern_match?(pattern, entry, remaining_entries, pattern_value=0.0)
	revised_pattern_value = revise_pattern_value(pattern_value, entry)
	pattern.delete(entry.account)
	if pattern.empty?
		revised_pattern_value == 0.0 ? return true : return false
	end
	remaining_entries.each do |current_entry|
		if potential_entry_match?(pattern, current_entry)
			return pattern_match?(pattern, current_entry, remaining_entries.delete(current_entry), revised_pattern_value)
		end
	end
end

def potential_entry_match?(pattern, entry)
	pattern.values.each { |key, value| return true if entry.account == key && entry.balance == value }
	false
end

# def entry_match?(current_entry, entry, pattern_matches)
# 	return false unless current_entry.date == entry.date
# 	all_matching_accounts = []
# 	pattern_matches.each do |key, value|
# 		puts '---'
# 		puts value
# 		all_matching_accounts.concat(value)
# 	end
# 	# puts current_entry.account
# 	# puts accounts.key(current_entry.account)
# 	# puts all_matching_accounts
# 	matching_accounts = all_matching_accounts.drop(all_matching_accounts.index(current_entry.account))
# 	return false unless matching_accounts.include?(entry.account)
# 	true
# end

file = FileTools.new('1. 1009-1108/AccountsAnalysis1011.xlsx', :accounts)
doc = file.contents

accounts = {}

doc.sheets.each do |sheet|
	accounts[sheet.name] = Account.new(sheet.rows) unless ['Accounts Summary', 'Closing to Capital'].include?(sheet.name)
end

all_ledger_entries = []

accounts.each do |key, value|
	value.entries.each do |entry|
		args = { date: entry.date, account: key, dr: entry.dr, cr: entry.cr, balance: entry.balance }
		all_ledger_entries << JournalEntry.new(args)
	end
end

all_ledger_entries.each { |entry| print "#{entry.inspect}\n" }

dr = 0
cr = 0

all_ledger_entries.each do |entry|
	cr += entry.cr
	dr += entry.dr
end

print "dr: #{dr}\n"
print "cr: #{cr}\n"
print "dr - cr: #{dr - cr}\n"

no_matches = []

# return patterns that include the required account with the right balance (dr/cr)
def get_pattern_matches(current_entry)
	pattern_matches = {}
	all_patterns = JournalTransaction.transaction_patterns
	all_patterns.each do |key, value|
		puts "=== #{key}.keys ==="
		value.keys.each { |t_key| puts t_key }
		puts '=================='
		puts "current_account: #{current_entry.account}"
		if value.keys.include?(current_entry.account) && value[current_entry.account] == current_entry.balance
			puts 'matching account value pair found in current pattern'
			pattern_matches[key] = all_patterns[key]
		end
	end
	pattern_matches
end


no_pattern_matches = []

until all_ledger_entries.empty?
	current_entry = all_ledger_entries[0]
	puts "current_entry: #{current_entry.inspect}"
	puts "current_entry.account: #{current_entry.account}"
	all_ledger_entries = all_ledger_entries.drop(1)
	pattern_matches = get_pattern_matches(current_entry)
	puts '=== matching patterns ==='
	pattern_matches.each { |key, _| puts key }
	puts '========================='
	await_return
	pattern_matches.empty? ? pattern_matches_found = false : pattern_matches_found = true
	if pattern_matches_found
		puts "\nEntry Matches:"
		puts '==='
		puts pattern_matches
		entry_matches = all_ledger_entries.select { |entry| entry_match?(current_entry, entry, pattern_matches) }
		entry_matches.each { |entry| puts entry.inspect }
		pattern_matches.each do |pattern|
			pattern[current_entry.account] = current_entry[current_entry.balance]
			potential_entries = []
			entry_matches.each do |entry|
				entry_account = Account.accounts.key(entry.account)
				if pattern.keys.include?(entry_matches) && pattern[entry_account] == entry.balance
					potential_entries << entry
				end
			end

		end
	else
		no_pattern_matches << current_entry
	end

	await_return

end



unless no_pattern_matches.empty?
	puts no_pattern_matches
	raise('there were entries that didn\'t even match a pattern!')
end
