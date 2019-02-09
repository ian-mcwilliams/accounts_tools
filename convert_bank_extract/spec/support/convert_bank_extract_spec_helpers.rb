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
    {
      'A1' => { value:  '01/01/2017' },
      'B1' => { value:  '2.30' },
      'C1' => { value:  nil },
      'D1' => { value:  nil },
      'E1' => { value:  'PAYMENT' },
      'F1' => { value:  'Town Borough     ON 12 JAN          CLP' },
      'A2' => { value:  '05/01/2017' },
      'B2' => { value:  nil },
      'C2' => { value:  '3300.00' },
      'D2' => { value:  nil },
      'E2' => { value:  'DIRECTDEP' },
      'F2' => { value:  'SOME RECRU    00000/00000        BGC' },
      'A3' => { value: '10/01/2017' },
      'B3' => { value: '5.65' },
      'C3' => { value:  nil },
      'D3' => { value:  nil },
      'E3' => { value:  'PAYMENT' },
      'F3' => { value:  'SOME STORE 3213      ON 12 JAN          CLP' }
    }
  end

end