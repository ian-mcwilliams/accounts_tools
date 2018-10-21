module ReportsSummaryCalculations

  def self.report_calculations(period, summary)
    calculation_spec = JSON.parse(File.read('tax_management/summary_calculations.json'))
    calculation_spec.each_with_object({}) do |(key, value), h|
      h[key] = {
        calculation_name: value['name'],
        calculation: value['calculation'] ? calculation(summary, value['calculation']) : nil
      }
    end
  end

  def self.calculation(summary, accounts)
    accounts.each_with_object({ dr: 0, cr: 0 }) do |account, h|
      h[:dr] += account_balance(summary, account, :dr)
      h[:cr] += account_balance(summary, account, :cr)
    end
  end

  def self.account_balance(summary, account, key)
    account_hash = summary.find { |item| item[:account_code] == account }
    raise("no account found for #{account}") unless account_hash
    account_hash[key]
  end

end