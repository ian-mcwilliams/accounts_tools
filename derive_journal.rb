require 'socket'
require 'time'
require 'awesome_print'
require_relative 'account'
require_relative 'journal_entry'
require_relative 'journal_transaction'
require_relative 'file_tools'
require_relative 'debug_tools'

class DeriveJournal

	def initialize(accounting_period, output_excel=false)
		@level = 0
		results = start_process(accounting_period)
		gen_results_output(results)
		output_excel ? results_msg = gen_results_output_excel(results) : results_msg = 'NO EXCEL RESULT FILE SAVED'
		puts "\n#{results_msg}"
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

	def get_entries_from_rows(rows)
		entries = []
		rows.each do |row|
			if row[0]
				entry = {}
				entry[:date] = date_cell_to_time(row[0])
				entry[:description] = row[1] || ''
				entry[:dr] = row[2].to_s.to_f.round(2)
				entry[:cr] = row[3].to_s.to_f.round(2) || 0.to_s.to_f.round(2)
				entry[:balance] = :dr if entry[:dr] > 0
				entry[:balance] = :cr if entry[:cr] > 0
				entries << entry
			end
		end
		entries
	end

	def date_cell_to_time(cell)
		return cell.to_time if cell.is_a?(Date)
		cell_split = cell.split('/')
		Time.new(cell_split[2], cell_split[1], cell_split[0])
	end


	def start_process(accounting_period)
		accounting_periods = [
				'1. 1009-1108/AccountsAnalysis1011.xlsx',
				'2. 1109-1110/AccountsAnalysisSep-Oct11.xlsx',
				'3. 1111-1210/AccountsAnalysis1112.xlsx',
				'4. 1211-1310/AccountsAnalysis1213.xlsx',
				'5. 1311-1410/AccountsAnalysis1314.xlsx',
				'DummyCorp/1. 1201-1212/AccountsAnalysis12.xlsx',
				'DummyCorp/1. 1301-1312/AccountsAnalysis13.xlsx',
				'LiveCorp/1. 1009-1108/Accounts1.xlsx',
				'LiveCorp/2. 1109-1110/Accounts2.xlsx'
		]

		file = FileTools.new(accounting_periods[accounting_period - 1], :accounts)
		doc = file.contents

		accounts = {}

		doc.sheets.each do |sheet|
			unless ['Accounts Summary', 'Closing to Capital'].include?(sheet.name)
				rows = sheet.rows.drop(2)[0..-5]
				entries = get_entries_from_rows(rows)
				accounts[sheet.name] = Account.new(entries: entries)
			end
		end

		@all_ledger_entries = []

		accounts.each do |key, value|
			puts "key: #{key}"
			value.entries.each do |entry|
				puts entry.inspect
				args = { date: entry.date, account: key, dr: entry.dr, cr: entry.cr, balance: entry.balance }
				b_fwd = false
				['brought forward', 'b/fwd'].each do |term|
					if entry.description.downcase.index(term)
						b_fwd = true; break
					end
				end
				entry.date == Time.new(2011, 11, 15) ? date_match = true : date_match = false
				entry.cr == 30.7 || entry.dr == 30.7 ? value_match = true : value_match = false
				filter = date_match && value_match
				key == Account.accounts[:capital] && entry.description.downcase.index('clos') ? closing = true : closing = false
				entry.description.downcase.index('closing to capital') ? closing_to_capital = true : closing_to_capital = false
				entry.cr == 0 && entry.dr == 0 ? null_entry = true : null_entry = false
				@all_ledger_entries << JournalEntry.new(args) unless null_entry || closing || closing_to_capital || b_fwd #|| !date_match
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
			@current_transaction.date = current_entry.date
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
		final_balance = 0
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
				puts "\noutstanding entries balance to: #{balance}"
				final_balance = final_balance + balance
			end
		end
		puts ''
		puts "final balance: #{final_balance.to_s.to_f.round(2)}"
	end

	def gen_results_output_excel(results)
		output_sheets = results_to_sheets(results)
		FileUtils.mkdir('run_results') unless Dir.exists?('run_results')
		files = []
		Dir.glob('run_results/*').each { |file| files << file[file.index('/')+1..file.index('.xlsx')-1] if file.index('run_result_') && !file.index('~') }
		index = 0
		files.each { |file| index = file[11..file.length].to_i if file[11..file.length].to_i >= index } unless files.empty?
		filepath = "run_results/run_result_#{index+1}.xlsx"
		FileTools.write_output_to_excel(filepath, output_sheets)
		"RESULTS SAVED TO: dev/accounts_tools/#{filepath}"
	end

	def results_to_sheets(results)
		# puts results.keys
		# puts results[:errors].keys
		# results[:errors].each { |entry| puts "#{entry.inspect}\n" }
		# raise
		results[:errors].each { |_, value| value.sort_by! { |entry| entry.date } }
		transactions_output = get_header_output.concat(get_transactions_output(results[:transactions]))
		no_matches_output = get_header_output.concat(get_entries_output(results[:errors][:no_pattern_matches])[0])
		no_successful_matches_output = get_header_output.concat(get_entries_output(results[:errors][:no_successful_pattern_matches])[0])
		sheets = []
		sheets << { sheet_name: 'transactions', output: transactions_output }
		sheets << { sheet_name: 'no_pattern_matches', output: no_matches_output }
		sheets << { sheet_name: 'no_successful_pattern_matches', output: no_successful_matches_output }
		# ap sheets
		sheets
	end

	def get_header_output
		[
				%w[Date Account Balance Value Adjusted Subtotal],
				[]
		]
	end

	def get_transactions_output(transactions)
		subtotal = 0
		output = []
		transactions.sort_by! { |transaction| transaction.date }
		transactions.each do |transaction|
			entries_output, subtotal = get_entries_output(transaction.journal_entries, subtotal)
			output.concat(entries_output)
			output << [] unless transaction == transactions.last
		end
		output
	end

	def get_entries_output(entries, subtotal=0)
		output = []
		entries.each do |entry|
			subtotal = subtotal.to_s.to_f.round(2) + entry.value.to_s.to_f.round(2)
			output << get_entry_output_array(entry, subtotal)
		end
		[output, subtotal.to_s.to_f.round(2)]
	end

	def get_entry_output_array(entry, subtotal)
		value_str = { dr: entry.dr, cr: entry.cr }[entry.balance]
		adjusted_str = entry.value
		subtotal_str = subtotal.to_s.to_f.round(2)
		[entry.date, entry.account, entry.balance.upcase, value_str, adjusted_str, subtotal_str]
	end

	def get_float_str(value)
		val_str = value.to_s
		val_str << '.00' unless val_str.index('.')
		val_str << '0' unless val_str.split('.')[1].length == 2
	end

end