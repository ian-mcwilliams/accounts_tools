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
		revised_pattern_value == 0.0 ? return_val = true : return_val = false
		return return_val
	else
		remaining_entries.each do |current_entry|
			if potential_entry_match?(pattern, current_entry)
				if pattern_match?(pattern, current_entry, remaining_entries.delete(current_entry), revised_pattern_value)
					@all_ledger_entries.delete!(current_entry)
					return true
				else
					return false
				end
			else
				return false
			end
		end
	end
	raise('deffo shouldn\'t get to this line of code, lol! maybe return false?')
end

def potential_entry_match?(pattern, entry)
	pattern.values.each { |key, value| return true if entry.account == key && entry.balance == value }
	false
end

file = FileTools.new('1. 1009-1108/AccountsAnalysis1011.xlsx', :accounts)
doc = file.contents

accounts = {}

doc.sheets.each do |sheet|
	accounts[sheet.name] = Account.new(sheet.rows) unless ['Accounts Summary', 'Closing to Capital'].include?(sheet.name)
end

@all_ledger_entries = []

accounts.each do |key, value|
	value.entries.each do |entry|
		args = { date: entry.date, account: key, dr: entry.dr, cr: entry.cr, balance: entry.balance }
		@all_ledger_entries << JournalEntry.new(args)
	end
end

@all_ledger_entries.each { |entry| print "#{entry.inspect}\n" }

dr = 0
cr = 0

@all_ledger_entries.each do |entry|
	cr += entry.cr
	dr += entry.dr
end

print "dr: #{dr}\n"
print "cr: #{cr}\n"
print "dr - cr: #{dr - cr}\n"

# return patterns that include the required account with the right balance (dr/cr)
def get_pattern_matches(current_entry)
	pattern_matches = []
	all_patterns = JournalTransaction.transaction_patterns
	all_patterns.each do |key, value|
		puts ">>>>>>>>>>>>>>> #{key}.keys"
		value.keys.each { |t_key| puts t_key }
		if value.keys.include?(current_entry.account) && value[current_entry.account] == current_entry.balance
			puts 'MATCHING ACCOUNT VALUE PAIR!!!!! <<<<<<<<<<<<<<<'
			pattern_matches << all_patterns[key]
			@matching_patterns << key
		end
	end
	pattern_matches
end

errors = {
		no_pattern_matches:							[],
		no_successful_pattern_matches:	[]
}

until @all_ledger_entries.empty?
	current_entry = @all_ledger_entries[0]
	puts ''
	puts ''
	puts '****************************************************************************************************'
	puts '****************************************************************************************************'
	puts '****************************************************************************************************'
	puts ''
	puts "current_entry: #{current_entry.inspect}"
	puts "current_entry.account: #{current_entry.account}"
	puts ''
	@all_ledger_entries = @all_ledger_entries.drop(1)
	@matching_patterns = []
	pattern_matches = get_pattern_matches(current_entry)
	puts ''
	puts '############### matching patterns ###############'
	puts @matching_patterns
	puts '#################################################'
	puts ''
	# await_return
	pattern_matches.empty? ? pattern_matches_found = false : pattern_matches_found = true
	if pattern_matches_found
		puts "\nEntry Matches:"
		entry_matches = @all_ledger_entries.select { |entry| current_entry.date == entry.date }
		entry_matches.each { |entry| puts entry.inspect }
		puts ''
		# await_return
		pattern_matches.each do |pattern|
			puts "\ncurrent_pattern = #{pattern}"
			errors[:no_successful_pattern_matches] << current_entry unless pattern_match?(pattern, current_entry, entry_matches)
		end
	else
		errors[:no_pattern_matches] << current_entry
	end

	# await_return

end

puts 'errors, if any --------- :'

errors.each do |key, value|
	unless value.empty?
		puts "error: #{key}"
		puts value
	end
end

puts 'all done now!!!!!!!'
