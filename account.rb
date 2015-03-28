require_relative 'ledger_entry'

class Account

  attr_accessor(:raw_data)

  def initialize(raw_data=nil)
    populate_account(raw_data) if raw_data
  end

  def populate_account(raw_data)
    @raw_data = raw_data
    content = raw_data.drop(2)[0..-6]
    @entries = []
    content.each do |row|
      @entries << LedgerEntry.new(row)
    end
    @entries.each { |entry| print "#{entry.inspect}\n" }
  end

end