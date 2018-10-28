module AccountsData
  def account_map
    {
        assets: [
            :cash,
            :ar
        ],
        liabilities: [
            :vat_payable,
            :ct_payable,
            :salary_payable,
            :paye_payable,
            :office_expenses_payable,
            :misc_payable,
            :directors_loans_payable
        ],
        equity: [
            :capital,
            :withdrawal,
            :ct_expenses,
            :net_sales,
            :retained_vat,
            :bank_expenses,
            :travel_expenses,
            :comms_expenses,
            :sundry_expenses,
            :salary_expenses,
            :empee_tax_ni_expenses,
            :emper_ni_expenses,
            :fines_expenses,
            :co_house_expenses,
            :comms_office_expenses,
            :rent_office_expenses,
            :power_office_expenses,
            :sundry_office_expenses
        ]
    }
  end
end