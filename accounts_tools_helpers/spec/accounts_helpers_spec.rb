require_relative 'spec_helper'

require 'date'

require_relative '../lib/accounts_helpers'


describe 'AccountsHelpers' do

  context 'pounds_to_pence' do

    context 'runs successfully' do
      tests = [
        { input: nil, expected: 0 },
        { input: 0, expected: 0 },
        { input: 1, expected: 100 },
        { input: 100, expected: 10000 },
        { input: -1, expected: -100 },
        { input: 0.0, expected: 0 },
        { input: 0.01, expected: 1 },
        { input: 0.1, expected: 10 },
        { input: 1.0, expected: 100 },
        { input: 1.01, expected: 101 },
        { input: '', expected: 0 },
        { input: '.', expected: 0 },
        { input: '0', expected: 0 },
        { input: '.0', expected: 0 },
        { input: '.00', expected: 0 },
        { input: '0.', expected: 0 },
        { input: '0.0', expected: 0 },
        { input: '0.00', expected: 0 },
        { input: '0.01', expected: 1 },
        { input: '.1', expected: 10 },
        { input: '0.1', expected: 10 },
        { input: '0.10', expected: 10 },
        { input: '1', expected: 100 },
        { input: '1.', expected: 100 },
        { input: '1.0', expected: 100 },
        { input: '1.00', expected: 100 },
        { input: '1.01', expected: 101 },
        { input: '1.1', expected: 110 },
        { input: '1.10', expected: 110 },
        { input: '-.', expected: 0 },
        { input: '-0', expected: 0 },
        { input: '-0.', expected: 0 },
        { input: '-.0', expected: 0 },
        { input: '-.00', expected: 0 },
        { input: '-0.01', expected: -1 },
        { input: '-0.1', expected: -10 },
        { input: '-1', expected: -100 },
        { input: '-1.01', expected: -101 }
      ]
      tests.each do |test|
        it "returns the correct result when passed a #{test[:input].class} as #{test[:input]}" do
          expect(AccountsHelpers.pounds_to_pence(test[:input])).to eq(test[:expected])
        end
      end
    end

    context 'pounds to pence exceptions' do
      tests = [
        0.001,
        0.99999,
        1.001,
        1.99999,
        '.000',
        '0.000',
        '0.001',
        '0.99999',
        '1.001',
        '1.99999'
      ]
      tests.each do |test|
        it "throws an exception when given more than 2 decimal places, example #{test.class} as #{test}" do
          msg = "max 2 decimal places allowed, got: #{test}"
          expect { AccountsHelpers.pounds_to_pence(test) }.to raise_error(msg)
        end
      end

      tests = [
        '..',
        ' ',
        '12_3',
        'abc',
        '£100',
        '$1.10'
      ]
      tests.each do |test|
        it "throws an exception if the input is a string without being in a valid number format, example #{test}" do
          msg = "string must be a valid number or float format, got: #{test}"
          expect { AccountsHelpers.pounds_to_pence(test) }.to raise_error(msg)
        end
      end

      tests = [
        DateTime.now,
        [],
        [0],
        {},
        { value: 0.01 }
      ]
      tests.each do |test|
        it "throws an exception if the class is not convertible" do
          msg = "class not valid: #{test.class}"
          expect { AccountsHelpers.pounds_to_pence(test) }.to raise_error(msg)
        end
      end
    end

  end

end
