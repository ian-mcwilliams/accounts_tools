module ConvertBankExtractSpecHelpers

  def self.test_hashes
    [
      {
        date: '10/01/2016',
        debit: 100,
        credit: nil,
        subcat: 'ABC',
        description: 'XYZ'
      },
      {
        date: '05/01/2016',
        debit: nil,
        credit: 200,
        subcat: 'DEF',
        description: 'UVW'
      },
      {
        date: '01/01/2016',
        debit: 50,
        credit: nil,
        subcat: 'GHI',
        description: 'RST'
      }
    ]
  end

  def self.integration_test_hashes
    [
      {
        date: '10/01/2017',
        debit: 5.65,
        credit: nil,
        subcat: 'PAYMENT',
        description: 'SOME STORE 3213      ON 12 JAN          CLP'
      },
      {
        date: '05/01/2017',
        debit: nil,
        credit: 3300.00,
        subcat: 'DIRECTDEP',
        description: 'SOME RECRU    00000/00000        BGC'
      },
      {
        date: '01/01/2017',
        debit: 2.30,
        credit: nil,
        subcat: 'PAYMENT',
        description: 'Town Borough     ON 12 JAN          CLP'
      }
    ]
  end

end