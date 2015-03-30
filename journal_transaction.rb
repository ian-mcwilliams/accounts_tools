class JournalTransaction

  attr_accessor(:journal_entries)

  def initialize(args)
    @journal_entries = args[:journal_entries] if args.has_key?(:journal_entries)
    @date = args[:date] if args.has_key?(:date)
    @description = args[:description] if args.has_key?[:description]
  end

  def self.transaction_patterns
    {
        issue_invoice: {
            ar:                       :dr,
            vat_payable:              :cr,
            revenue:                  :cr,
            retained_vat:             :cr
        },
        receive_remittance: {
            cash:                     :dr,
            ar:                       :cr
        },
        owner_investment: {
            cash:                     :dr,
            capital:                  :cr
        },
        pay_vat: {
            vat_payable:              :dr,
            cash:                     :cr
        },
        pay_corporation_tax: {
            ct_payable:               :dr,
            cash:                     :cr
        },
        employee_works: {
            salary_expenses:          :dr,
            empee_tax_ni_expenses:    :dr,
            emper_ni_expenses:        :dr,
            salary_payable:           :cr,
            paye_payable:             :cr
        },
        pay_salary: {
            salary_payable:           :dr,
            cash:                     :cr
        },
        pay_paye: {
            paye_payable:             :dr,
            cash:                     :cr
        },
        accrue_office_expenses: {
            comms_office_expenses:    :dr,
            rent_office_expenses:     :dr,
            power_office_expenses:    :dr,
            sundry_office_expenses:   :dr,
            office_expenses_payable:  :cr
        },
        pay_office_expenses: {
            office_expenses_payable:  :dr,
            cash:                     :cr
        },
        pay_misc_payable: {
            misc_payable:             :dr,
            cash:                     :cr
        },
        bank_payments: {
            bank_expanses:            :dr,
            cash:                     :cr
        },
        travel_payments: {
            travel_expenses:          :dr,
            cash:                     :cr
        },
        comms_payments: {
            comms_expenses:           :dr,
            cash:                     :cr
        },
        sundry_payments: {
            sundry_expenses:          :dr,
            cash:                     :cr
        },
        fines_payments: {
            fines_expenses:           :dr,
            cash:                     :cr
        }
    }
  end

end