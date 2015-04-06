require 'time'

class LedgerEntry

  attr_accessor(:date, :description, :dr, :cr, :balance)

  def initialize(raw_data=nil)
    populate_entry(raw_data) if raw_data
  end

  def populate_entry(raw_data)
    @date = raw_data[0].to_time
    @description = raw_data[1] || ''
    @dr = raw_data[2].to_s.to_f.round(2)
    @cr = raw_data[3].to_s.to_f.round(2) || 0.to_s.to_f.round(2)
    @balance = :dr if @dr > 0
    @balance = :cr if @cr > 0
  end

end