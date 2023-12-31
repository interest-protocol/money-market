module money_market::ipx_money_market_sdk_interface {

  use sui::coin::{Self, Coin};
  use sui::clock::{Clock};
  use sui::tx_context::{Self, TxContext};
  use sui::pay;

  use ipx::ipx::{IPXStorage};

  use sui_dollar::suid::{SUID, SuiDollarStorage};

  use oracle::ipx_oracle::{Price as PricePotato};

  use library::utils::{handle_coin_vector, public_transfer_coin};

  use money_market::interest_rate_model::{InterestRateModelStorage};
  use money_market::ipx_money_market_core::{Self as money_market, MoneyMarketStorage};

  entry public fun accrue<T>(
    money_market_storage: &mut MoneyMarketStorage, 
    interest_rate_model_storage: &InterestRateModelStorage, 
    clock_object: &Clock
  ) {
    money_market::accrue<T>(money_market_storage, interest_rate_model_storage, clock_object);    
  }

  entry public fun accrue_suid(
    money_market_storage: &mut MoneyMarketStorage, 
    clock_object: &Clock
  ) {
    money_market::accrue_suid(money_market_storage, clock_object);
  }

  entry public fun deposit<T>(
    money_market_storage: &mut MoneyMarketStorage, 
    interest_rate_model_storage: &InterestRateModelStorage,
    clock_object: &Clock,
    asset_vector: vector<Coin<T>>,
    asset_value: u64,
    ctx: &mut TxContext
  ) { 
       money_market::deposit<T>(
          money_market_storage,
          interest_rate_model_storage, 
          clock_object,
          handle_coin_vector<T>(asset_vector, asset_value, ctx),
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
  ) {
    let sender = tx_context::sender(ctx);
    
    public_transfer_coin(
      money_market::withdraw<T>(
        money_market_storage,
        interest_rate_model_storage,
        price_potatoes,
        clock_object,
        shares_to_remove,
        sender,
        ctx
      ), 
      sender
    );
  }

  public fun borrow<T>(
    money_market_storage: &mut MoneyMarketStorage, 
    interest_rate_model_storage: &InterestRateModelStorage,
    price_potatoes: vector<PricePotato>,
    clock_object: &Clock,
    borrow_value: u64,
    ctx: &mut TxContext    
  ) {
    let sender = tx_context::sender(ctx);
    
    public_transfer_coin(
      money_market::borrow<T>(
        money_market_storage,
        interest_rate_model_storage,
        price_potatoes,
        clock_object,
        borrow_value,
        sender,
        ctx
      ), 
     sender
    ); 
  }

  public fun repay<T>(
    money_market_storage: &mut MoneyMarketStorage, 
    interest_rate_model_storage: &InterestRateModelStorage,
    clock_object: &Clock,
    asset_vector: vector<Coin<T>>,
    principal_to_repay: u64,
    ctx: &mut TxContext   
  ) {
    let sender = tx_context::sender(ctx);

    let asset = coin::zero<T>(ctx);

    pay::join_vec(&mut asset, asset_vector);
    
    public_transfer_coin(
      money_market::repay<T>(
        money_market_storage,
        interest_rate_model_storage,
        clock_object,
        asset,
        principal_to_repay,
        sender,
        ctx
      ), 
      sender
    );
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
  ) {
    let sender = tx_context::sender(ctx);

    public_transfer_coin(
      money_market::borrow_suid(
        money_market_storage,
        interest_rate_model_storage,
        suid_storage,
        price_potatoes,
        clock_object,
        borrow_value,
        sender,
        ctx
      ), 
      sender
    );
  } 


  public fun repay_suid(
    money_market_storage: &mut MoneyMarketStorage, 
    suid_storage: &mut SuiDollarStorage,
    clock_object: &Clock,
    asset_vector: vector<Coin<SUID>>,
    principal_to_repay: u64,
    ctx: &mut TxContext 
  ) {

    let sender = tx_context::sender(ctx);

    let asset = coin::zero<SUID>(ctx);

    pay::join_vec(&mut asset, asset_vector);

    public_transfer_coin(
      money_market::repay_suid(
        money_market_storage,
        suid_storage,
        clock_object,
        asset,
        principal_to_repay,
        sender,
        ctx
      ), 
      sender
    );
  }

  entry public fun get_rewards<T>(
    money_market_storage: &mut MoneyMarketStorage, 
    interest_rate_model_storage: &InterestRateModelStorage,
    ipx_storage: &mut IPXStorage, 
    clock_object: &Clock,
    ctx: &mut TxContext 
  ) {

    let sender = tx_context::sender(ctx);

    public_transfer_coin(
      money_market::get_rewards<T>(
        money_market_storage,
        interest_rate_model_storage,
        ipx_storage,
        clock_object,
        sender,
        ctx
      ),
      sender
    );
  }

  entry public fun get_all_rewards(
    money_market_storage: &mut MoneyMarketStorage, 
    interest_rate_model_storage: &InterestRateModelStorage,
    ipx_storage: &mut IPXStorage, 
    clock_object: &Clock,
    ctx: &mut TxContext 
  ) {

    let sender = tx_context::sender(ctx);

    public_transfer_coin(
      money_market::get_all_rewards(
        money_market_storage,
        interest_rate_model_storage,
        ipx_storage,
        clock_object,
        sender,
        ctx
      ),
      sender
    );    
  }

  public fun liquidate<C, L>(
    money_market_storage: &mut MoneyMarketStorage,
    interest_rate_model_storage: &InterestRateModelStorage,
    price_potatoes: vector<PricePotato>,
    clock_object: &Clock,
    asset_vector: vector<Coin<L>>,
    asset_value: u64,
    borrower: address,
    ctx: &mut TxContext
  ) { 

    let sender = tx_context::sender(ctx);

    public_transfer_coin(
      money_market::liquidate<C, L>(
      money_market_storage,
      interest_rate_model_storage,
      price_potatoes,
      clock_object,
      handle_coin_vector<L>(asset_vector, asset_value, ctx),
      borrower,
      sender,
      ctx
    ),
    sender
  );
   }

  public fun liquidate_suid<C>(
    money_market_storage: &mut MoneyMarketStorage,
    interest_rate_model_storage: &InterestRateModelStorage,
    suid_storage: &mut SuiDollarStorage,
    price_potatoes: vector<PricePotato>,
    clock_object: &Clock,
    asset_vector: vector<Coin<SUID>>,
    asset_value: u64,
    borrower: address,
    ctx: &mut TxContext
  ) {

    let sender = tx_context::sender(ctx);

    public_transfer_coin<SUID>(
      money_market::liquidate_suid<C>(
        money_market_storage,
        interest_rate_model_storage,
        suid_storage,
        price_potatoes,
        clock_object,
        handle_coin_vector<SUID>(asset_vector, asset_value, ctx),
        borrower,
        sender,
        ctx
    ),
    sender
  );
  }
}