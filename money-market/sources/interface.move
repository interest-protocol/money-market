module money_market::ipx_money_market_interface {

  use sui::coin::{Coin};
  use sui::clock::{Clock};
  use sui::tx_context::{Self, TxContext};

  use ipx::ipx::{IPXStorage, IPX};

  use sui_dollar::suid::{SUID, SuiDollarStorage};

  use oracle::ipx_oracle::{Price as PricePotato};

  use money_market::interest_rate_model::{InterestRateModelStorage};
  use money_market::ipx_money_market_core::{Self as money_market, MoneyMarketStorage};

  public fun accrue<T>(
    money_market_storage: &mut MoneyMarketStorage, 
    interest_rate_model_storage: &InterestRateModelStorage, 
    clock_object: &Clock
  ) {
    money_market::accrue<T>(money_market_storage, interest_rate_model_storage, clock_object);    
  }

  public fun accrue_suid(
    money_market_storage: &mut MoneyMarketStorage, 
    clock_object: &Clock
  ) {
    money_market::accrue_suid(money_market_storage, clock_object);
  }

  public fun deposit<T>(
    money_market_storage: &mut MoneyMarketStorage, 
    interest_rate_model_storage: &InterestRateModelStorage,
    clock_object: &Clock,
    asset: Coin<T>,
    ctx: &mut TxContext
  ) { 
    money_market::deposit<T>(
      money_market_storage,
      interest_rate_model_storage, 
      clock_object,
      asset,
      tx_context::sender(ctx),
      ctx
    );
  } 

  public fun withdraw<T>(
    money_market_storage: &mut MoneyMarketStorage, 
    interest_rate_model_storage: &InterestRateModelStorage,
    price_potatoes: vector<PricePotato>,
    clock_object: &Clock,
    shares_to_remove: u64,
    ctx: &mut TxContext
  ): Coin<T> {
    money_market::withdraw<T>(
      money_market_storage,
      interest_rate_model_storage,
      price_potatoes,
      clock_object,
      shares_to_remove,
      tx_context::sender(ctx),
      ctx
    )
  }

  public fun borrow<T>(
    money_market_storage: &mut MoneyMarketStorage, 
    interest_rate_model_storage: &InterestRateModelStorage,
    price_potatoes: vector<PricePotato>,
    clock_object: &Clock,
    borrow_value: u64,
    ctx: &mut TxContext    
  ): Coin<T> {
    money_market::borrow<T>(
      money_market_storage,
      interest_rate_model_storage,
      price_potatoes,
      clock_object,
      borrow_value,
      tx_context::sender(ctx),
      ctx
    )  
  }

  public fun repay<T>(
    money_market_storage: &mut MoneyMarketStorage, 
    interest_rate_model_storage: &InterestRateModelStorage,
    clock_object: &Clock,
    asset: Coin<T>,
    principal_to_repay: u64,
    ctx: &mut TxContext   
  ): Coin<T> {
    money_market::repay<T>(
      money_market_storage,
      interest_rate_model_storage,
      clock_object,
      asset,
      principal_to_repay,
      tx_context::sender(ctx),
      ctx
    )
  }

  entry public fun enter_market<T>(money_market_storage: &mut MoneyMarketStorage, ctx: &mut TxContext) {
    money_market::enter_market<T>(money_market_storage, tx_context::sender(ctx));
  }

  public fun exit_market<T>(
    money_market_storage: &mut MoneyMarketStorage, 
    interest_rate_model_storage: &InterestRateModelStorage,
    price_potatoes: vector<PricePotato>,
    clock_object: &Clock,
    ctx: &mut TxContext
  ) {
    money_market::exit_market<T>(money_market_storage, interest_rate_model_storage, price_potatoes, clock_object, tx_context::sender(ctx), ctx);
  }

  public fun borrow_suid(
    money_market_storage: &mut MoneyMarketStorage,
    interest_rate_model_storage: &InterestRateModelStorage,
    suid_storage: &mut SuiDollarStorage,
    price_potatoes: vector<PricePotato>,
    clock_object: &Clock,
    borrow_value: u64,
    ctx: &mut TxContext
  ): Coin<SUID> {
    money_market::borrow_suid(
      money_market_storage,
      interest_rate_model_storage,
      suid_storage,
      price_potatoes,
      clock_object,
      borrow_value,
      tx_context::sender(ctx),
      ctx
    )
  } 


  public fun repay_suid(
    money_market_storage: &mut MoneyMarketStorage, 
    suid_storage: &mut SuiDollarStorage,
    clock_object: &Clock,
    asset: Coin<SUID>,
    principal_to_repay: u64,
    ctx: &mut TxContext 
  ): Coin<SUID> {
    money_market::repay_suid(
      money_market_storage,
      suid_storage,
      clock_object,
      asset,
      principal_to_repay,
      tx_context::sender(ctx),
      ctx
    )
  }

  public fun get_rewards<T>(
    money_market_storage: &mut MoneyMarketStorage, 
    interest_rate_model_storage: &InterestRateModelStorage,
    ipx_storage: &mut IPXStorage, 
    clock_object: &Clock,
    ctx: &mut TxContext 
  ): Coin<IPX> {
    money_market::get_rewards<T>(
      money_market_storage,
      interest_rate_model_storage,
      ipx_storage,
      clock_object,
      tx_context::sender(ctx),
      ctx
    )
  }

  public fun get_all_rewards(
    money_market_storage: &mut MoneyMarketStorage, 
    interest_rate_model_storage: &InterestRateModelStorage,
    ipx_storage: &mut IPXStorage, 
    clock_object: &Clock,
    ctx: &mut TxContext 
  ): Coin<IPX> {
    money_market::get_all_rewards(
      money_market_storage,
      interest_rate_model_storage,
      ipx_storage,
      clock_object,
      tx_context::sender(ctx),
      ctx
    )  
  }

  public fun liquidate<C, L>(
    money_market_storage: &mut MoneyMarketStorage,
    interest_rate_model_storage: &InterestRateModelStorage,
    price_potatoes: vector<PricePotato>,
    clock_object: &Clock,
    asset: Coin<L>,
    borrower: address,
    ctx: &mut TxContext
  ): Coin<L> { 
      money_market::liquidate<C, L>(
      money_market_storage,
      interest_rate_model_storage,
      price_potatoes,
      clock_object,
      asset,
      borrower,
      tx_context::sender(ctx),
      ctx
    )
  }

  public fun liquidate_suid<C>(
    money_market_storage: &mut MoneyMarketStorage,
    interest_rate_model_storage: &InterestRateModelStorage,
    suid_storage: &mut SuiDollarStorage,
    price_potatoes: vector<PricePotato>,
    clock_object: &Clock,
    asset: Coin<SUID>,
    borrower: address,
    ctx: &mut TxContext
  ): Coin<SUID> {
    money_market::liquidate_suid<C>(
      money_market_storage,
      interest_rate_model_storage,
      suid_storage,
      price_potatoes,
      clock_object,
      asset,
      borrower,
      tx_context::sender(ctx),
      ctx
    )
  }
}