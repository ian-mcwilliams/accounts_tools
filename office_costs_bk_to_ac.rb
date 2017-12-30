require 'simple_xlsx_reader'
require_relative 'file_tools'


class OfficeCostsBkToAc

  def initialize(period)
    import_file(period)
    @sheets = {}
    @file.sheets.each {|sheet| @sheets[sheet.name] = sheet.rows}
    reformat_business_sheet
    @ledger_hash.each do |key, value|
      puts key
      value.each do |item|
        puts "#{item[:date]},#{item[:description]},#{item[:dr] || ''},#{item[:cr] || ''}"
      end
      puts ''
    end
  end

  def import_file(period)
    filename = {
        seven: '7.1511-1610/_BK2_OfficeSpaceCosts_2015-16'
    }[period.to_sym]
    filepath = "#{FileTools.get_rel_path}F3Mmedia/Internal/ACcounts/LiveCorp/#{filename}.xlsx"
    @file = SimpleXlsxReader.open(filepath)
  end

  def reformat_business_sheet
    sheet_to_row_hashes
    row_hashes_to_transaction_row_hashes
    transaction_row_hashes_to_journal_hashes
    journal_hashes_to_ledger_hash
  end

  def journal_hashes_to_ledger_hash
    @ledger_hash = {}
    @journal_hashes.each do |journal_hash|
      ledger_hash = journal_hash.clone
      account = ledger_hash.delete(:account)
      ledger_hash[ledger_hash.delete(:type)] = ledger_hash.delete(:amount)
      @ledger_hash[account] = [] unless @ledger_hash.has_key?(account)
      @ledger_hash[journal_hash[:account]] << ledger_hash
    end
  end

  def sheet_to_row_hashes
    @row_hashes = @sheets['Business'][1..-1].map do |row|
      {
          date_paid: row[4],
          date_due: row[3],
          description: row[0],
          paid_by_im: row[1],
          paid_by_business: row[2],
          im_share: row[8],
          business_share: row[10],
          ms_payable_to_im: row[6],
          im_payable_to_business: row[7],
          business_payable_to_im: row[9]
      }
    end
  end

  def row_hashes_to_transaction_row_hashes
    @transaction_row_hashes = @row_hashes.select do |row_hash|
      (row_hash[:paid_by_im] || row_hash[:paid_by_business]) && row_hash[:description] != 'TOTALS:'
    end
    @transaction_row_hashes.each do |transaction_row_hash|
      valid = true
      valid = false if transaction_row_hash[:paid_by_im] && transaction_row_hash[:paid_by_business]
      valid = false if transaction_row_hash[:paid_by_im].nil? && transaction_row_hash[:paid_by_business].nil?
      valid = false unless transaction_row_hash[:date_due] && transaction_row_hash[:date_paid]
      valid = false unless transaction_row_hash[:description]
      raise("malformed row: '#{transaction_row_hash}'") unless valid
    end
  end

  def transaction_row_hashes_to_journal_hashes
    @journal_hashes = []
    @transaction_row_hashes.each do |transaction_row_hash|
      current_hashes = []
      current_hashes << {
          date: transaction_row_hash[:date_due].strftime('%d/%m/%Y'),
          description: transaction_row_hash[:description],
          account: get_account_from_description(transaction_row_hash[:description]),
          type: :dr,
          amount: transaction_row_hash[:business_share]
      }
      if transaction_row_hash[:paid_by_im]
        current_hashes << {
            date: transaction_row_hash[:date_due].strftime('%d/%m/%Y'),
            description: transaction_row_hash[:description],
            account: :ap,
            type: :cr,
            amount: transaction_row_hash[:business_payable_to_im]
        }
      else
        current_hashes += [
            {
                date: transaction_row_hash[:date_due].strftime('%d/%m/%Y'),
                description: transaction_row_hash[:description],
                account: :ap,
                type: :cr,
                amount: transaction_row_hash[:business_share]
            },
            {
                date: transaction_row_hash[:date_paid].strftime('%d/%m/%Y'),
                description: transaction_row_hash[:description],
                account: :ap,
                type: :dr,
                amount: transaction_row_hash[:business_share]
            },
            {
                date: transaction_row_hash[:date_paid].strftime('%d/%m/%Y'),
                description: "#{transaction_row_hash[:description]} (MS share: recoup from IM)",
                account: :ap,
                type: :dr,
                amount: transaction_row_hash[:im_payable_to_business]
            },
            {
                date: transaction_row_hash[:date_paid].strftime('%d/%m/%Y'),
                description: transaction_row_hash[:description],
                account: :cash,
                type: :cr,
                amount: transaction_row_hash[:paid_by_business]
            }
        ]
      end
      unless current_hashes_balance?(current_hashes)
        raise("current_hashes do not balance:\n#{current_hashes.join("\n")}")
      end
      @journal_hashes += current_hashes
    end
  end

  def current_hashes_balance?(current_hashes)
    balance = 0.00
    current_hashes.each do |current_hash|
      balance += {
          cr: current_hash[:amount].to_f,
          dr: current_hash[:amount].to_f - (current_hash[:amount].to_f * 2)
      }[current_hash[:type]]
    end
    balance == 0.00
  end

  def get_account_from_description(description)
    return :rent_expenses if ['Rent Expenses', 'Council Tax Expenses', 'Water Expenses'].include?(description)
    return :power_expenses if ['Electric Expenses', 'Gas Expenses'].include?(description)
    return :sundry_expenses if description == 'Contents Insurance Expenses'
    return :comms_expenses if description == 'Virgin Broadband Expenses'
    raise("'#{description}' is not a known description")
  end

end

OfficeCostsBkToAc.new('seven')
