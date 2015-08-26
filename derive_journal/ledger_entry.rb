class LedgerEntry

  attr_accessor(:date, :description, :dr, :cr, :balance)

  def initialize(entry)
    populate_entry(entry) if entry
  end

  def populate_entry(entry)
    @date = entry[:date]
    @description = entry[:description]
    @dr = entry[:dr]
    @cr = entry[:cr]
    @balance = entry[:balance]
  end

end