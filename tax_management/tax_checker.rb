require_relative 'reports_summary'
require_relative 'ch_accounts'

module TaxChecker

  def self.generate_reports_summary(period, inputs)
    accounts_summaries = AccountsIngress.accounts_summaries_ingress(period, true)
    ReportsSummary.reports_summary(accounts_summaries, inputs)
  end

  def self.calculation_inputs(period = nil)
    all_periods = JSON.parse(File.read('tax_management/calculation_inputs.json'))['calculation_inputs']
    period ? all_periods[period] : all_periods
  end

end
