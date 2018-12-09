require_relative 'reports_summary'
require_relative 'ch_accounts'
require_relative 'ct_return'

module TaxChecker

  def self.generate_ct_return_inputs(period, inputs, test = false)
    summary = generate_reports_summary(period, inputs, test)
    CtReturn.corporation_tax_return_inputs(summary, inputs[:current], inputs[:previous])
  end

  def self.generate_ch_accounts(period, inputs, test = false)
    summary = generate_reports_summary(period, inputs, test)
    ChAccounts.abbreviated_accounts(summary)
  end

  def self.generate_reports_summary(period, inputs, test = false)
    accounts_summaries = AccountsIngress.accounts_summaries_ingress(period, test)
    ReportsSummary.reports_summary(accounts_summaries, inputs)
  end

  def self.calculation_inputs(period)
    raise("the period must be greater than 0 - got #{period}") unless period > 0
    all_periods = JSON.parse(File.read('tax_management/calculation_inputs.json'))['calculation_inputs']
    inputs_hash = { current: all_periods.find { |item| item['period'] == period } }
    inputs_hash[:previous] = all_periods.find { |item| item['period'] == period - 1 } if period > 1
    inputs_hash
  end

end
