require_relative 'env'
require_relative 'tax_management/lib/tax_checker'
require 'awesome_print'

inputs = TaxChecker.calculation_inputs(7)
ap TaxChecker.generate_ch_accounts(7, inputs)
ap TaxChecker.generate_ct_return_inputs(7, inputs)
