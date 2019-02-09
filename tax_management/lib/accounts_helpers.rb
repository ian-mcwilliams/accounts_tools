module AccountsHelpers

  def self.account_balance(summary, account, key)
    account_hash = summary.find { |item| item[:account_code] == account.gsub('-', '') }
    raise("no account found for #{account}") unless account_hash
    account[0] == '-' ? account_hash[key] - (account_hash[key] * 2) : account_hash[key]
  end

end