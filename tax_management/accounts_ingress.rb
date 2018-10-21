module AccountsIngress

  def self.accounts_summaries_ingress(period)
    unless period.is_a?(Integer) && period > 0
      raise('period must be an integer greater than 0')
    end
    accounts_summaries = {
      current_period: accounts_summary_array(period),
      previous_period: nil
    }
    if period > 1
      accounts_summaries[:previous_period] = accounts_summary_array(period - 1)
    end
    accounts_summaries
  end

  def self.accounts_summary_rows(period)
    file = SimpleXlsxReader.open(accounts_file_path(period))
    file.sheets.each do |sheet|
      return sheet.rows if sheet.name == 'Accounts Summary'
    end
  end

  def self.accounts_file_path(period)
    rel_dropbox_path = '../../Dropbox/'
    livecorp_path = 'F3Mmedia/Internal/ACcounts/LiveCorp/'
    accounts_file_path = "#{period}.#{period_strings[period - 1]}/Accounts#{period}.xlsx"
    "#{rel_dropbox_path}#{livecorp_path}#{accounts_file_path}"
  end

  def self.period_strings
    %w[
      1009-1108
      1109-1110
      1111-1210
      1211-1310
      1311-1410
      1411-1510
      1511-1610
      1611-1710
      1711-1810
    ]
  end

  def self.accounts_summary_array(period)
    rows = accounts_summary_rows(period)
    (1..27).each_with_object([]) do |i, a|
      account_code = rows[i][1][/^\D\d+/]
      account_name = rows[i][1].delete("#{account_code}. ")
      a << {
        account_code: account_code,
        account_name: account_name,
        account_balance: { debit: :dr, credit: :cr }[rows[i][2].downcase.to_sym],
        dr: (rows[i][3] * 100).round.to_i,
        cr: (rows[i][4] * 100).round.to_i,
        balance: (rows[i][5] * 100).round.to_i
      }
    end
  end

end