module money_market::ipx_money_market_utils {

  use std::ascii::{String};
  use std::vector;

  use sui::coin::{Coin};
  use sui::clock::{Clock};
  use sui::sui::{SUI};
  use sui::tx_context::{TxContext};

  use oracle::ipx_oracle::{Self, Price as PricePotato, OracleStorage};

  use pyth::state::{State as PythState};
  use pyth::price_info::{PriceInfoObject};

  use wormhole::state::{State as WormholeState};

  use switchboard_std::aggregator::{Aggregator};

  public fun get_prices(
    storage: &mut OracleStorage, 
    wormhole_state: &WormholeState,
    pyth_state: &PythState,
    bufs: vector<vector<u8>>,
    price_info_objects: &mut vector<PriceInfoObject>,
    pyth_fees: vector<Coin<SUI>>,
    clock_object: &Clock,
    switchboard_feeds: &vector<Aggregator>, 
    coin_names: vector<String>,
    ctx: &mut TxContext    
  ): vector<PricePotato> {
    let price_potatoes = vector::empty<PricePotato>();

    let length = vector::length(&coin_names);
    let index = 0;

    while (index < length) {
      
      let potato = ipx_oracle::get_price(
        storage,
        wormhole_state,
        pyth_state,
        vector::pop_back(&mut bufs),
        vector::borrow_mut(price_info_objects, index),
        vector::pop_back(&mut pyth_fees),
        clock_object,
        vector::borrow(switchboard_feeds, index),
        vector::pop_back(&mut coin_names),
        ctx        
      );

      vector::push_back(&mut price_potatoes, potato);

      index = index + 1;
    };

    vector::destroy_empty(pyth_fees);
    vector::destroy_empty(bufs);
    vector::destroy_empty(coin_names);

    price_potatoes
  }
}