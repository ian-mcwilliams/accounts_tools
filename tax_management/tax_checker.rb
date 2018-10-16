require_relative '../file_tools'
require 'awesome_print'

module TaxChecker

  def self.reports_summary_ingress(period)
    ap reports_summary_hash(period)
  end

  def self.reports_summary_rows(period)
    file = SimpleXlsxReader.open('../../Dropbox/F3Mmedia/Internal/ACcounts/LiveCorp/7.1511-1610/Reports7.xlsx')
    file.sheets.each do |sheet|
      return sheet.rows if sheet.name == 'Reports Summary'
    end
  end

  def self.reports_summary_hash(period)
    rows = reports_summary_rows(period)
    (2..28).each_with_object({}) do |i, h|
      h[rows[i][1]] = {
        balance: { debit: :dr, credit: :cr }[rows[i][2].downcase.to_sym],
        current_period: {
          dr: (rows[i][3].round(2) * 100).to_i,
          cr: (rows[i][4].round(2) * 100).to_i,
          balance: (rows[i][5].round(2) * 100).to_i
        },
        previous_period: {
          dr: (rows[i][6].round(2) * 100).to_i,
          cr: (rows[i][7].round(2) * 100).to_i,
          balance: (rows[i][8].round(2) * 100).to_i
        }
      }
    end
  end

end
