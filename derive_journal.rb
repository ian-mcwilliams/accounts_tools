require 'socket'
require_relative 'account'
require_relative 'journal_entry'
require_relative 'journal_transaction'
require_relative 'file_tools'
require_relative 'debug_tools'

class DeriveJournal

	def initialize(accounting_period)
		@level = 0
		results = start_process(accounting_period)
		gen_results_output(results)
	end

	def revise_pattern_value(current_value, entry)
		puts "pattern_value: #{current_value}"
		puts "entry_value: #{{ dr: entry.dr, cr: entry.cr }[entry.balance]}"
		revised_value = 0 + current_value
		revised_value.round(2) + entry.value.round(2)
	end

	def pattern_match?(pattern, entry, entry_matches, pattern_value)
		puts "level: #{@level}, pattern = #{pattern}, value: #{pattern_value}"
		if pattern.empty?
			pattern_value == 0.0 ? return_val = true : return_val = false
			return return_val
		end
		entry_matches.each do |current_entry|
			puts current_entry.inspect
			puts "pattern: #{pattern.inspect}"
			result = entry_match?(pattern, current_entry, entry_matches, pattern_value)
			return true if result
		end
		false
	end

	def entry_match?(pattern, entry, entries, pattern_value)
		# if entry.dr == 30.7
		# 	puts "pattern: #{pattern.inspect}"
		# 	puts "account: #{entry.account}"
		# 	puts "balance: #{entry.balance}"
		# 	puts "1st: #{pattern.has_key?(entry.account)}, 2nd: #{pattern[entry.account] == entry.balance}"
		# end
		if pattern.has_key?(entry.account) && pattern[entry.account] == entry.balance
			remaining_entries = []
			entries.each { |current_entry| remaining_entries << current_entry unless current_entry == entry }
			@level += 1
			sub_pattern = {}.merge(pattern)
			sub_pattern.delete(entry.account)
			if pattern_match?(sub_pattern, entry, remaining_entries, pattern_value.round(2) + entry.value.round(2))
				matching_entry = @all_ledger_entries.delete(entry)
				@current_transaction.journal_entries << matching_entry
				pattern.delete(entry.account)
				puts 'HIT TRUE'
				@level -= 1
				return true
			else
				puts 'HIT FALSE'
				@level -= 1
				return false
			end
		end
		puts 'HIT NO POTENTIAL MATCHES'
		false
	end



	# return patterns that include the required account with the right balance (dr/cr)
	def get_pattern_matches(current_entry)
		pattern_matches = {}
		all_patterns = JournalTransaction.transaction_patterns
		all_patterns.each do |key, value|
			if value.keys.include?(current_entry.account) && value[current_entry.account] == current_entry.balance
				pattern_matches[key] = all_patterns[key]
				@matching_patterns << key
			end
		end
		pattern_matches
	end


	def start_process(accounting_period)
		accounting_periods = [
				'1. 1009-1108/AccountsAnalysis1011.xlsx',
				'2. 1109-1110/AccountsAnalysisSep-Oct11.xlsx',
				'3. 1111-1210/AccountsAnalysis1112.xlsx',
				'4. 1211-1310/AccountsAnalysis1213.xlsx',
				'5. 1311-1410/AccountsAnalysis1314.xlsx'
		]

		file = FileTools.new(accounting_periods[accounting_period - 1], :accounts)
		doc = file.contents

		accounts = {}

		doc.sheets.each do |sheet|
			accounts[sheet.name] = Account.new(sheet.rows) unless ['Accounts Summary', 'Closing to Capital', 'L2. CT'].include?(sheet.name)
		end

		@all_ledger_entries = []

		accounts.each do |key, value|
			puts "key: #{key}"
			value.entries.each do |entry|
				puts entry.inspect
				args = { date: entry.date, account: key, dr: entry.dr, cr: entry.cr, balance: entry.balance }
				['brought forward', 'b/fwd'].include?(entry.description.downcase) ? b_fwd = true : b_fwd = false
				entry.date == Time.new(2011, 11, 15) ? date_match = true : date_match = false
				entry.cr == 30.7 || entry.dr == 30.7 ? value_match = true : value_match = false
				filter = date_match && value_match
				key == Account.accounts[:capital] && entry.description.downcase.index('clos') ? closing = true : closing = false
				@all_ledger_entries << JournalEntry.new(args) unless closing || b_fwd #|| !date_match
			end
		end

		puts "\n\n\n\n\n\n\n##################################################\n\n\n\n\n\n\n\n\n\n"

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

		errors = {
				no_pattern_matches:							[],
				no_successful_pattern_matches:	[]
		}

		transactions = []

		until @all_ledger_entries.empty?
			@current_transaction = JournalTransaction.new
			current_entry = @all_ledger_entries[0]
			@current_transaction.journal_entries << current_entry
			puts ''
			puts ''
			puts '****************************************************************************************************'
			puts inset_str("     ENTRY COUNT: #{@all_ledger_entries.count}     ", '*', 100)
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
				puts 'Entry Matches:'
				entry_matches = @all_ledger_entries.select { |entry| current_entry.date == entry.date }
				entry_matches.each { |entry| puts entry.inspect }
				puts ''
				# await_return
				match_found = false
				pattern_matches.each do |key, value|
					puts "\ncurrent_pattern = #{value}"
					value.delete(current_entry.account)
					match_found = pattern_match?(value, current_entry, entry_matches, current_entry.value)
					if match_found
						@current_transaction.pattern_name = key
						transactions << @current_transaction
						break
					end
				end
				unless match_found
					@all_ledger_entries.delete(current_entry)
					errors[:no_successful_pattern_matches] << current_entry
				end
			else
				@all_ledger_entries.delete(current_entry)
				errors[:no_pattern_matches] << current_entry
			end

			puts ''
			errors.each { |key, value| puts "#{key}.count: #{value.count}" }

		end
		{ transactions: transactions, errors: errors }
	end

	def gen_results_output(results)
		transactions = results[:transactions]
		errors = results[:errors]
		puts "\n\n\n"
		oph('     TRANSACTIONS IDENTIFIED     ')
		puts ''
		transactions.each do |transaction|
			puts transaction.pattern_name
			transaction.journal_entries.each { |entry| puts entry.inspect }
			puts ''
		end
		puts "\n\n\n"

		oph('     UNMATCHED ENTRIES     ')
		puts ''
		errors.each { |key, value| puts "#{key}: #{value.count}" }
		puts ''
		errors.each do |key, value|
			unless value.empty?
				puts ''
				puts "error: #{key}"
				balance = 0
				entries = value.sort_by { |error| error.date }
				entries.each do |entry|
					balance = (balance + entry.value).to_s.to_f.round(2) unless entry.value.nil?
					output_str = entry.date.strftime('%Y-%m-%d')
					output_str << ' ' until output_str.length > 10
					output_str << entry.account.to_s
					output_str << ' ' until output_str.length > 40
					output_str << "#{entry.balance.to_s.upcase} "
					output_str << { dr: entry.dr, cr: entry.cr }[entry.balance].to_s
					output_str << ' ' until output_str.length > 52
					output_str << "value: #{entry.value}"
					output_str << ' ' until output_str.length > 70
					output_str << "subtotal: #{balance}"
					puts output_str
				end
				puts ''
				puts "outstanding entries balance to: #{balance}"
			end
		end
		puts ''
		puts 'all done now!!!!!!!'
	end

end