require_relative 'tax_checker_spec_helpers'

module SummaryCalculationsSpecHelpers
  include TaxCheckerSpecHelpers

  def self.all_calculations_non_zero_array(period)
    TaxCheckerSpecHelpers.initial_calculation_non_zero_array +
      TaxCheckerSpecHelpers.input_calculation_non_zero_array(period) +
      TaxCheckerSpecHelpers.composite_calculation_non_zero_array(period)
  end

end