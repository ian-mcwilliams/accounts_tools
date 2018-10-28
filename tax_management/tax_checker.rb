require_relative 'reports_summary'

module TaxChecker
  include ReportsSummary

  def self.generate_reports(period)
    ReportsSummary.reports_summary(period)
  end

end
