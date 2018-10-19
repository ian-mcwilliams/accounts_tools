require_relative '../file_tools'

module TaxChecker

  def self.reports_summary(period)
    accounts_summaries = accounts_summaries_ingress(period)
    accounts_summaries.values.each do |summary|
      summary[:balances] = assets_liabilities_equity_balances_hash(summary)
      accounts_summary_validation(summary)
    end
    {
      current_period: {
        accounts_summary: accounts_summaries[:current_period],
        calculations: report_calculations(accounts_summaries[:current_period])
      },
      previous_period: {
        accounts_summary: accounts_summaries[:previous_period],
        calculations: report_calculations(accounts_summaries[:previous_period])
      }
    }
  end

  def self.report_calculations(reports_summary_hash)
    {}
  end

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
      a << {
        account_name: rows[i][1],
        account_balance: { debit: :dr, credit: :cr }[rows[i][2].downcase.to_sym],
        dr: (rows[i][3] * 100).round.to_i,
        cr: (rows[i][4] * 100).round.to_i,
        balance: (rows[i][5] * 100).round.to_i
      }
    end
  end

  def self.accounts_summary_validation(summary_array)
    summary_array.each do |account_hash|
      calculation = {
        dr: account_hash[:dr] - account_hash[:cr],
        cr: account_hash[:cr] - account_hash[:dr]
      }[account_hash[:account_balance]]
      unless calculation == account_hash[:balance]
        raise("summary validation failed for account '#{account_hash[:account_name]}'")
      end
    end
    assets_less_liabilities = summary_array[:balances][:assets] - summary_array[:balances][:liabilities]
    unless assets_less_liabilities == summary_array[:balances][:equity]
      raise('assets less liabilities is not equal to equity')
    end
  end

  def self.assets_liabilities_equity_balances_hash(summary_array)
    account_names = account_name_arrays_by_balance(summary_array)
    assets_balance = specified_accounts_balance(account_names[:assets], summary_array)
    liabilities_balance = specified_accounts_balance(account_names[:liabilities], summary_array)
    equities_debit_balance = specified_accounts_balance(account_names[:equity_debit], summary_array)
    equities_credit_balance = specified_accounts_balance(account_names[:equity_credit], summary_array)
    {
      assets: assets_balance,
      liabilities: 0 - liabilities_balance,
      equities: equities_debit_balance - equities_credit_balance
    }
  end

  def self.account_name_arrays_by_balance(summary_array)
    all_account_names = summary_array.map { |item| item[:account_name] }
    account_names = {
      assets: all_account_names.select { |item| item[/^A\d+.*$/] },
      liabilities: all_account_names.select { |item| item[/^L\d+.*$/] }
    }
    equities_account_names = all_account_names.select { |item| item[/^E\d+.*$/] }
    account_names[:equities_debit] = equities_account_names.select do |account_name|
      summary_array.find { |item| item[:account_name] == account_name }[:account_balance] == :dr
    end
    account_names[:equities_credit] = equities_account_names.select do |account_name|
      summary_array.find { |item| item[:account_name] == account_name }[:account_balance] == :cr
    end
    account_names
  end

  def self.specified_accounts_balance(specified_accounts, summary_array)
    assets_balances = summary_array.each_with_object([]) do |account_hash, a|
      a << account_hash[:balance] if specified_accounts.include?(account_hash[:account_name])
    end
    assets_balances.inject(0, :+)
  end

end
