require 'time'

class LedgerEntry

  attr_accessor(:date, :description, :dr, :cr, :balance)

  def initialize(raw_data=nil)
    populate_entry(raw_data) if raw_data
  end

  def populate_entry(raw_data)
    @date = date_cell_to_time(raw_data[0])
    @description = raw_data[1] || ''
    @dr = raw_data[2].to_s.to_f.round(2)
    @cr = raw_data[3].to_s.to_f.round(2) || 0.to_s.to_f.round(2)
    @balance = :dr if @dr > 0
    @balance = :cr if @cr > 0
  end

  def date_cell_to_time(cell)
    return cell.to_time if cell.is_a?(Date)
    cell_split = cell.split('/')
    Time.new(cell_split[2], cell_split[1], cell_split[0])
  end

end