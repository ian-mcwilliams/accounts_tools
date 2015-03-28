require 'time'

class LedgerEntry

  attr_accessor(:date, :description, :dr, :cr)

  def initialize(raw_data=nil)
    populate_entry(raw_data) if raw_data
  end

  def populate_entry(raw_data)
    @date = raw_data[0].to_time
    @description = raw_data[1]
    @dr = raw_data[2].to_s.to_f
    @cr = raw_data[3] || 0.to_s.to_f
  end

end