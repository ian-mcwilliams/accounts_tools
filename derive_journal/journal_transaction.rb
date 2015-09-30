class JournalTransaction

  attr_accessor(:journal_entries, :date, :description, :pattern_name)

  def initialize(args={})
    @journal_entries = []
    if args.has_key?(:journal_entries)
      if args[:journal_entries].is_a?(Array)
        @journal_entries.concat(args[:journal_entries])
      else
        @journal_entries << args[:journal_entries]
      end
    end
    @date = args[:date] if args.has_key?(:date)
    @description = args[:description] if args.has_key?(:description)
    @pattern_name = args[:pattern_name] if args.has_key?(:pattern_name)
  end

  def self.transaction_patterns
    {
        issue_invoice: {
            ar:                             :dr,
            vat_payable:                    :cr,
            net_sales:                      :cr,
        },
        issue_invoice_flat_rate: {
            ar:                             :dr,
            vat_payable:                    :cr,
            net_sales:                      :cr,
            retained_vat:                   :cr
        },
        receive_remittance: {
            cash:                           :dr,
            ar:                             :cr
        },
        owner_investment: {
            cash:                           :dr,
            capital:                        :cr
        },
        withdrawal: {
            withdrawal:                     :dr,
            cash:                           :cr
        },
        reverse_withdrawal:{
            cash:                           :dr,
            withdrawal:                     :cr
        },
        pay_vat: {
            vat_payable:                    :dr,
            cash:                           :cr
        },
        vat_refund: {
            cash:                           :dr,
            vat_payable:                    :cr
        },
        pay_corporation_tax: {
            ct_payable:                     :dr,
            cash:                           :cr
        },
        accrue_corporation_tax: {
            capital:                        :dr,
            ct_payable:                     :cr
        },
        employee_works: {
            salary_expenses:                :dr,
            empee_tax_ni_expenses:          :dr,
            emper_ni_expenses:              :dr,
            salary_payable:                 :cr,
            paye_payable:                   :cr
        },
        accrue_salary: {
            salary_expenses:                :dr,
            salary_payable:                 :cr
        },
        refund_overpaid_salary: {
            cash:                           :dr,
            salary_expenses:                :cr
        },
        pay_salary: {
            salary_payable:                 :dr,
            cash:                           :cr
        },
        # accrue_and_pay_salary: {
        #     salary_expenses:                :dr,
        #     cash:                           :cr
        # },
        accrue_paye: {
            empee_tax_ni_expenses:          :dr,
            emper_ni_expenses:              :dr,
            paye_payable:                   :cr
        },
        accrue_paye_empee: {
            empee_tax_ni_expenses:          :dr,
            paye_payable:                   :cr
        },
        accrue_paye_emper: {
            emper_ni_expenses:              :dr,
            paye_payable:                   :cr
        },
        pay_paye: {
            paye_payable:                   :dr,
            cash:                           :cr
        },
        refund_pay_paye: {
            cash:                           :dr,
            paye_payable:                   :cr
        },
        accrue_comms_office_expenses: {
            comms_office_expenses:          :dr,
            office_expenses_payable:        :cr
        },
        accrue_rent_office_expenses: {
            rent_office_expenses:           :dr,
            office_expenses_payable:        :cr
        },
        accrue_power_office_expenses: {
            power_office_expenses:          :dr,
            office_expenses_payable:        :cr
        },
        accrue_sundry_office_expenses: {
            sundry_office_expenses:         :dr,
            office_expenses_payable:        :cr
        },
        pay_office_expenses: {
            office_expenses_payable:        :dr,
            cash:                           :cr
        },
        pay_misc_payable: {
            misc_payable:                   :dr,
            cash:                           :cr
        },
        incoming_loan: {
            cash:                           :dr,
            misc_payable:                   :cr
        },
        misc_expense: {
            comms_expenses:                 :dr,
            misc_payable:                   :cr
        },
        reverse_office_expenses: {
            cash:                           :dr,
            office_expenses_payable:        :cr
        },
        accrue_vat_fine: {
            fines_expenses:                 :dr,
            vat_payable:                    :cr
        },
        accrue_ct_fine: {
            fines_expenses:                 :dr,
            ct_payable:                     :cr
        }
    }.merge(self.direct_expense_transactions)
  end

  def self.direct_expense_transactions
    transactions = {
        bank_payments: {
            bank_expenses:                  :dr,
            cash:                           :cr
        },
        travel_payments: {
            travel_expenses:                :dr,
            cash:                           :cr
        },
        comms_payments: {
            comms_expenses:                 :dr,
            cash:                           :cr
        },
        sundry_payments: {
            sundry_expenses:                :dr,
            cash:                           :cr
        },
        fines_payments: {
            fines_expenses:                 :dr,
            cash:                           :cr
        },
        co_house_payments: {
            co_house_expenses:              :dr,
            cash:                           :cr
        }
    }
    transactions.merge(self.reverse_transactions(transactions))
  end

  def self.reverse_transactions(transactions)
    new_transactions = {}
    transactions.each do |key, entries|
      new_entries = {}
      entries.each do |account, balance|
        new_entries[account] = balance[1].to_s.gsub('dr', 'cr').gsub('cr', 'dr').to_sym
      end
      new_transactions["reverse_#{key.to_s}".to_sym] = new_entries
    end
    new_transactions
  end

end