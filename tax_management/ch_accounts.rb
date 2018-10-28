module ChAccounts

  def self.verify_accounts(accounts)
    %i[current previous].each_with_object([]) do |period, a|
      unless accounts[period][:total_net_assets] == accounts[period][:shareholders_funds]
        a << [
          "total net assets (liabilities) [",
          currency_string(accounts[period][:total_net_assets]),
          "] different from shareholders' funds [",
          currency_string(accounts[period][:shareholders_funds]),
          '] for ',
          period,
          ' period'
        ].join
      end
    end
  end

  def self.currency_string(raw_value)
    string_value = raw_value.to_s
    2.times do
      break if string_value.length > 2
      string_value = "0#{string_value}"
    end
    "£#{string_value[0..-3]}.#{string_value[-2..-1]}"
  end

end