module ConvertBankExtractSpecHelpers

  def self.test_hashes
    [
      {
        date: '10/01/2016',
        debit: 100,
        credit: 0,
        subcat: 'ABC',
        description: 'XYZ'
      },
      {
        date: '05/01/2016',
        debit: 0,
        credit: 200,
        subcat: 'DEF',
        description: 'UVW'
      },
      {
        date: '01/01/2016',
        debit: 50,
        credit: 0,
        subcat: 'GHI',
        description: 'RST'
      }
    ]
  end

end