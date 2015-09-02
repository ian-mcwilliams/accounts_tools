class Account

  attr_accessor(:name, :code, :balance, :dr_value, :cr_value, :value, :adj_value)

  def initialize(account_hash)
    @code = account_hash[:code]
    @name = account_hash[:name]
    @balance = account_hash[:balance]
    @dr_value = account_hash[:dr_value]
    @cr_value = account_hash[:cr_value]
    @value = @dr_value - @cr_value if @balance == :dr
    @value = @cr_value - @dr_value if @balance == :cr
    @adj_value = @cr_value - @dr_value
  end

end