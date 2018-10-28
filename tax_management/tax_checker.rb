require_relative 'reports_summary'

module TaxChecker
  include ReportsSummary

  def self.generate_reports(period)
    accounts_summaries = AccountsIngress.accounts_summaries_ingress(period)
    ReportsSummary.reports_summary(accounts_summaries, calculation_inputs(period))
  end

  def self.calculation_inputs(period = nil)
    all_periods = JSON.parse(File.read('tax_management/calculation_inputs.json'))['calculation_inputs']
    period ? all_periods[period] : all_periods
  end

end
