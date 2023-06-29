module dashboard::dashboard {
  
  use std::ascii::{String};
  use std::vector;

  use sui::clock::{Clock};

  use money_market::ipx_money_market_core::{Self, MoneyMarketStorage};
  use money_market::interest_rate_model::{InterestRateModelStorage};

  struct Market has drop, store {
    borrow_rate: u64,
    supply_rate: u64,
    cash: u64,
    collateral_enabled: bool,
    allocation_points: u256,
    user_principal: u64,
    user_shares: u64,
    user_loan_pending_rewards: u256,
    user_collateral_pending_rewards: u256,
    total_collateral_elastic: u64,
    total_collateral_base: u64,
    total_loan_elastic: u64,
    total_loan_base: u64,
    borrow_cap: u64,
    collateral_cap: u64,
    ltv: u256,
    accrued_timestamp: u64
  }

  public fun get_markets(storage: &mut MoneyMarketStorage, interest_rate_model_storage: &InterestRateModelStorage, clock_object: &Clock, user: address): vector<Market> {
    let result = vector::empty<Market>();

    let all_market_keys = *ipx_money_market_core::get_all_markets_keys(storage);
    let user_markets_in = if (ipx_money_market_core::account_markets_in_exists(storage, user)) 
      { *ipx_money_market_core::get_user_markets_in(storage, user) } else { vector::empty<String>() };
    let index = 0;
    let length = vector::length(&all_market_keys);

    while (index < length) {

      let key = *vector::borrow(&all_market_keys, index);

      let no_user = !ipx_money_market_core::account_exists(storage, user, key);

      let (user_shares, user_principal, _, _, _, _) = if (no_user) {
        (0, 0, 0, 0, 0, 0)
      } else {
        ipx_money_market_core::get_account_info_by_key(storage, user, key)
      };

      let (user_collateral_pending_rewards, user_loan_pending_rewards) 
        = if (no_user) {
          (0, 0)
        } else {
          ipx_money_market_core::get_pending_rewards_by_key(storage, interest_rate_model_storage, clock_object, key, user)
        };

      let (_, accrued_timestamp, borrow_cap, collateral_cap, cash, _, ltv, _, allocation_points, _, _, total_collateral_base, total_collateral_elastic, total_loan_base, total_loan_elastic, _) = ipx_money_market_core::get_market_info_by_key(storage, key);

      let market = Market {
        borrow_rate: ipx_money_market_core::get_borrow_rate_per_ms_by_key(storage, interest_rate_model_storage, key),
        supply_rate: ipx_money_market_core::get_supply_rate_per_ms_by_key(storage, interest_rate_model_storage, key),
        cash,
        collateral_enabled: vector::contains(&user_markets_in, &key),
        allocation_points,
        user_principal,
        user_shares,
        user_collateral_pending_rewards,
        user_loan_pending_rewards,
        total_collateral_elastic,
        total_collateral_base,
        total_loan_elastic,
        total_loan_base,
        borrow_cap,
        collateral_cap,
        ltv,
        accrued_timestamp
      };

      vector::push_back(&mut result, market);

      index = index + 1;
    };

    result
  }
}