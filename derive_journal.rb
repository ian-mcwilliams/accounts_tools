require 'socket'
require_relative 'account'
require_relative 'journal_entry'
require_relative 'journal_transaction'
require_relative 'file_tools'
require_relative 'debug_tools'

class DeriveJournal

	def initialize(accounting_period)
		results = start_process(accounting_period)
		gen_results_output(results)
	end

	def revise_pattern_value(current_value, entry)
		{
				dr:	current_value.round(2) - entry.dr.round(2),
				cr:	current_value.round(2) + entry.cr.round(2)
		}[entry.balance]
	end

	def pattern_match?(pattern, entry, entry_matches, pattern_value=0.0)
		revised_pattern_value = revise_pattern_value(pattern_value, entry)
		pattern.delete(entry.account)
		if pattern.empty?
			revised_pattern_value == 0.0 ? return_val = true : return_val = false
			return return_val
		end
		entry_matches.each do |current_entry|
			result = entry_match?(pattern, current_entry, entry_matches, revised_pattern_value)
			return true if result
		end
		false
	end

	def entry_match?(pattern, entry, entries, revised_pattern_val)
		if pattern.has_key?(entry.account) && pattern[entry.account] == entry.balance
			remaining_entries = []
			entries.each { |current_entry| remaining_entries << current_entry unless current_entry == entry }
			if pattern_match?(pattern, entry, remaining_entries, revised_pattern_val)
				matching_entry = @all_ledger_entries.delete(entry)
				@current_transaction.journal_entries << matching_entry
				puts 'HIT TRUE'
				return true
			else
				puts 'HIT FALSE'
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
			puts ">>>>>>>>>>>>>>> #{key}.keys"
			value.keys.each { |t_key| puts t_key }
			if value.keys.include?(current_entry.account) && value[current_entry.account] == current_entry.balance
				puts 'MATCHING ACCOUNT VALUE PAIR!!!!! <<<<<<<<<<<<<<<'
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
			accounts[sheet.name] = Account.new(sheet.rows) unless ['Accounts Summary', 'Closing to Capital'].include?(sheet.name)
		end

		@all_ledger_entries = []

		accounts.each do |key, value|
			value.entries.each do |entry|
				args = { date: entry.date, account: key, dr: entry.dr, cr: entry.cr, balance: entry.balance }
				@all_ledger_entries << JournalEntry.new(args) #if args[:date] == Time.new(2011, 01, 20)
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
				puts ''
				# await_return
				match_found = false
				pattern_matches.each do |key, value|
					puts "current_pattern = #{value}"
					entry_matches.each { |entry| puts entry.inspect }
					match_found = pattern_match?(value, current_entry, entry_matches)
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
				entries = value.sort_by { |error| error.date }
				entries.each do |entry|
					output_str = entry.date.strftime('%Y-%m-%d')
					output_str << ' ' until output_str.length > 10
					output_str << entry.account.to_s
					output_str << ' ' until output_str.length > 40
					output_str << "#{entry.balance.to_s.upcase} "
					output_str << { dr: entry.dr, cr: entry.cr }[entry.balance].to_s
					puts output_str
				end
			end
		end
		puts ''
		puts 'all done now!!!!!!!'
	end

end