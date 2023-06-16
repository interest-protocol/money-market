module money_market::ipx_money_market_publisher_interface {

  use sui::object::{id_address};
  use sui::coin::{Coin};
  use sui::clock::{Clock};
  use sui::package::{Publisher};
  use sui::tx_context::{TxContext};

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
    ipx_storage: &mut IPXStorage, 
    clock_object: &Clock,
    asset: Coin<T>,
    publisher: &Publisher,
    ctx: &mut TxContext
  ): Coin<IPX> {
      
    money_market::deposit<T>(
      money_market_storage,
      interest_rate_model_storage, 
      ipx_storage,
      clock_object,
      asset,
      id_address(publisher),
      ctx
    )
  } 

  public fun withdraw<T>(
    money_market_storage: &mut MoneyMarketStorage, 
    interest_rate_model_storage: &InterestRateModelStorage,
    ipx_storage: &mut IPXStorage, 
    price_potatoes: vector<PricePotato>,
    clock_object: &Clock,
    shares_to_remove: u64,
    publisher: &Publisher,
    ctx: &mut TxContext
  ): (Coin<T>, Coin<IPX>) {

    money_market::withdraw<T>(
      money_market_storage,
      interest_rate_model_storage,
      ipx_storage,
      price_potatoes,
      clock_object,
      shares_to_remove,
      id_address(publisher),
      ctx
    )
  }

  public fun borrow<T>(
    money_market_storage: &mut MoneyMarketStorage, 
    interest_rate_model_storage: &InterestRateModelStorage,
    ipx_storage: &mut IPXStorage, 
    price_potatoes: vector<PricePotato>,
    clock_object: &Clock,
    borrow_value: u64,
    publisher: &Publisher,
    ctx: &mut TxContext    
  ): (Coin<T>, Coin<IPX>) {

    money_market::borrow<T>(
      money_market_storage,
      interest_rate_model_storage,
      ipx_storage,
      price_potatoes,
      clock_object,
      borrow_value,
      id_address(publisher),
      ctx
    )  
  }

  public fun repay<T>(
    money_market_storage: &mut MoneyMarketStorage, 
    interest_rate_model_storage: &InterestRateModelStorage,
    ipx_storage: &mut IPXStorage, 
    clock_object: &Clock,
    asset: Coin<T>,
    principal_to_repay: u64,
    publisher: &Publisher,
    ctx: &mut TxContext   
  ): (Coin<T>, Coin<IPX>) {
    money_market::repay<T>(
      money_market_storage,
      interest_rate_model_storage,
      ipx_storage,
      clock_object,
      asset,
      principal_to_repay,
      id_address(publisher),
      ctx
    )
  }

  entry public fun enter_market<T>(money_market_storage: &mut MoneyMarketStorage, publisher: &Publisher) {
    money_market::enter_market<T>(money_market_storage, id_address(publisher));
  }

  public fun exit_market<T>(
    money_market_storage: &mut MoneyMarketStorage, 
    interest_rate_model_storage: &InterestRateModelStorage,
    price_potatoes: vector<PricePotato>,
    clock_object: &Clock,
    publisher: &Publisher
  ) {
    money_market::exit_market<T>(money_market_storage, interest_rate_model_storage, price_potatoes, clock_object, id_address(publisher));
  }

  public fun borrow_suid(
    money_market_storage: &mut MoneyMarketStorage,
    interest_rate_model_storage: &InterestRateModelStorage,
    ipx_storage: &mut IPXStorage,
    suid_storage: &mut SuiDollarStorage,
    price_potatoes: vector<PricePotato>,
    clock_object: &Clock,
    borrow_value: u64,
    publisher: &Publisher,
    ctx: &mut TxContext
  ): (Coin<SUID>, Coin<IPX>) {
    
    money_market::borrow_suid(
      money_market_storage,
      interest_rate_model_storage,
      ipx_storage,
      suid_storage,
      price_potatoes,
      clock_object,
      borrow_value,
      id_address(publisher),
      ctx
    )
  } 


  public fun repay_suid(
    money_market_storage: &mut MoneyMarketStorage, 
    ipx_storage: &mut IPXStorage, 
    suid_storage: &mut SuiDollarStorage,
    clock_object: &Clock,
    asset: Coin<SUID>,
    principal_to_repay: u64,
    publisher: &Publisher,
    ctx: &mut TxContext 
  ): (Coin<SUID>, Coin<IPX>) {
    money_market::repay_suid(
      money_market_storage,
      ipx_storage,
      suid_storage,
      clock_object,
      asset,
      principal_to_repay,
      id_address(publisher),
      ctx
    )
  }

  public fun get_rewards<T>(
    money_market_storage: &mut MoneyMarketStorage, 
    interest_rate_model_storage: &InterestRateModelStorage,
    ipx_storage: &mut IPXStorage, 
    clock_object: &Clock,
    publisher: &Publisher,
    ctx: &mut TxContext 
  ): Coin<IPX> {
    money_market::get_rewards<T>(
      money_market_storage,
      interest_rate_model_storage,
      ipx_storage,
      clock_object,
      id_address(publisher),
      ctx
    )
  }

  public fun get_all_rewards(
    money_market_storage: &mut MoneyMarketStorage, 
    interest_rate_model_storage: &InterestRateModelStorage,
    ipx_storage: &mut IPXStorage, 
    clock_object: &Clock,
    publisher: &Publisher,
    ctx: &mut TxContext 
  ): Coin<IPX> {
    money_market::get_all_rewards(
      money_market_storage,
      interest_rate_model_storage,
      ipx_storage,
      clock_object,
      id_address(publisher),
      ctx
    )  
  }

  public fun liquidate<C, L>(
    money_market_storage: &mut MoneyMarketStorage,
    interest_rate_model_storage: &InterestRateModelStorage,
    ipx_storage: &mut IPXStorage,
    price_potatoes: vector<PricePotato>,
    clock_object: &Clock,
    asset: Coin<L>,
    borrower: address,
    publisher: &Publisher,
    ctx: &mut TxContext
  ): Coin<L> { 
      money_market::liquidate<C, L>(
      money_market_storage,
      interest_rate_model_storage,
      ipx_storage,
      price_potatoes,
      clock_object,
      asset,
      borrower,
      id_address(publisher),
      ctx
    )
  }

  public fun liquidate_suid<C>(
    money_market_storage: &mut MoneyMarketStorage,
    interest_rate_model_storage: &InterestRateModelStorage,
    ipx_storage: &mut IPXStorage,
    suid_storage: &mut SuiDollarStorage,
    price_potatoes: vector<PricePotato>,
    clock_object: &Clock,
    asset: Coin<SUID>,
    borrower: address,
    publisher: &Publisher,
    ctx: &mut TxContext
  ): Coin<SUID> {
    money_market::liquidate_suid<C>(
      money_market_storage,
      interest_rate_model_storage,
      ipx_storage,
      suid_storage,
      price_potatoes,
      clock_object,
      asset,
      borrower,
      id_address(publisher),
      ctx
    )
  }
}