require_relative 'tax_checker_spec_helpers'

module ReportsSummarySpecHelpers
  include TaxCheckerSpecHelpers

  def self.full_reports_summary_balanced_output
    current_period_calculations = TaxCheckerSpecHelpers.initial_calculation_non_zero_array +
      TaxCheckerSpecHelpers.input_calculation_non_zero_array(:current) +
      TaxCheckerSpecHelpers.composite_calculation_non_zero_array(:current)
    previous_period_calculations = TaxCheckerSpecHelpers.initial_calculation_non_zero_array +
      TaxCheckerSpecHelpers.input_calculation_non_zero_array(:previous) +
      TaxCheckerSpecHelpers.composite_calculation_non_zero_array(:previous)
    balances = accounting_equation_hash_balanced_non_zero
    {
      current: {
        accounts: TaxCheckerSpecHelpers.non_zero_account_array,
        balances: balances,
        calculations: current_period_calculations
      },
      previous: {
        accounts: TaxCheckerSpecHelpers.non_zero_account_array,
        balances: balances,
        calculations: previous_period_calculations
      }
    }
  end

  def self.accounting_equation_hash_balanced_non_zero
    { assets: -2, liabilities: 14, equity: 12 }
  end

end