module ChAccountsSpecHelpers

  def self.abbreviated_accounts_input_accounts
    accounts = [
      { account_code: 'A1', account_name: 'CASH', account_balance: :dr, dr: 15000, cr: 5000, balance: 10000 },
      { account_code: 'A2', account_name: 'AR', account_balance: :dr, dr: 12000, cr: 2000, balance: 10000 },
      { account_code: 'S21', account_name: 'Creditors < 1 year', account_balance: :cr, dr: 3000, cr: 13000, balance: 10000 },
      { account_code: 'S22', account_name: 'Creditors > 1 year', account_balance: :cr, dr: 2000, cr: 12000, balance: 10000 },
      { account_code: 'S7', account_name: 'Share', account_balance: :cr, dr: 0, cr: 10000, balance: 10000 },
      { account_code: 'S20', account_name: 'Profit & Loss Acc', account_balance: :cr, dr: 500, cr: 10500, balance: 10000 }
    ]
    summary = { accounts: accounts, balances: nil }
    { current: summary, previous: summary }
  end

  def self.abbreviated_accounts_hash
    data = {
      debtors: 10000,
      cash_in_bank_and_at_hand: 10000,
      creditors_within_one_year: -10000,
      creditors_after_one_year: -10000,
      called_up_share_capital: 10000,
      profit_and_loss_account: 10000
    }
    { current: data, previous: data }
  end

  def self.ch_verify_accounts_tests
    nil_assets_current = "total net assets (liabilities) [£0.00] different from shareholders' funds [£0.01] for current period"
    nil_funds_current = "total net assets (liabilities) [£0.01] different from shareholders' funds [£0.00] for current period"
    nil_assets_previous = "total net assets (liabilities) [£0.00] different from shareholders' funds [£0.01] for previous period"
    nil_funds_previous = "total net assets (liabilities) [£0.01] different from shareholders' funds [£0.00] for previous period"
    [
      {
        title: 'no messages are returned where all values are zero',
        inputs: {
          current: { total_net_assets: 0, shareholders_funds: 0 },
          previous: { total_net_assets: 0, shareholders_funds: 0 },
        },
        expected: []
      },
      {
        title: 'no messages are returned where all values are one',
        inputs: {
          current: { total_net_assets: 1, shareholders_funds: 1 },
          previous: { total_net_assets: 1, shareholders_funds: 1 },
        },
        expected: []
      },
      {
        title: 'a message is returned where all values are zero except current funds',
        inputs: {
          current: { total_net_assets: 0, shareholders_funds: 1 },
          previous: { total_net_assets: 0, shareholders_funds: 0 },
        },
        expected: [nil_assets_current]
      },
      {
        title: 'a message is returned where all values are zero except current assets',
        inputs: {
          current: { total_net_assets: 1, shareholders_funds: 0 },
          previous: { total_net_assets: 0, shareholders_funds: 0 },
        },
        expected: [nil_funds_current]
      },
      {
        title: 'a message is returned where all values are zero except previous funds',
        inputs: {
          current: { total_net_assets: 0, shareholders_funds: 0 },
          previous: { total_net_assets: 0, shareholders_funds: 1 },
        },
        expected: [nil_assets_previous]
      },
      {
        title: 'a message is returned where all values are zero except previous assets',
        inputs: {
          current: { total_net_assets: 0, shareholders_funds: 0 },
          previous: { total_net_assets: 1, shareholders_funds: 0 },
        },
        expected: [nil_funds_previous]
      },
      {
        title: 'two messages are returned where both assets are zero, both funds are one',
        inputs: {
          current: { total_net_assets: 0, shareholders_funds: 1 },
          previous: { total_net_assets: 0, shareholders_funds: 1 },
        },
        expected: [nil_assets_current, nil_assets_previous]
      },
      {
        title: 'two messages are returned where both assets are one, both funds are zero',
        inputs: {
          current: { total_net_assets: 1, shareholders_funds: 0 },
          previous: { total_net_assets: 1, shareholders_funds: 0 },
        },
        expected: [nil_funds_current, nil_funds_previous]
      },
      {
        title: 'two messages are returned where current has zero assets, one funds and previous has one assets, zero funds',
        inputs: {
          current: { total_net_assets: 0, shareholders_funds: 1 },
          previous: { total_net_assets: 1, shareholders_funds: 0 },
        },
        expected: [nil_assets_current, nil_funds_previous]
      },
      {
        title: 'two messages are returned where current has one assets, zero funds and previous has zero assets, one funds',
        inputs: {
          current: { total_net_assets: 1, shareholders_funds: 0 },
          previous: { total_net_assets: 0, shareholders_funds: 1 },
        },
        expected: [nil_funds_current, nil_assets_previous]
      }
    ]
  end

end