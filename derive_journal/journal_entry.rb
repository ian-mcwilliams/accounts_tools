require_relative 'account'

class JournalEntry

  attr_accessor(:account, :dr, :cr, :date, :balance, :value)

  def initialize(args)
    @account, @dr, @cr, @balance = Account.accounts.key(args[:account]), args[:dr], args[:cr], args[:balance]
    @date = args[:date] if args[:date]
    @value = { dr: @dr, cr: @cr }[@balance]
    @value -= @value * 2 if @balance == :dr
  end

end