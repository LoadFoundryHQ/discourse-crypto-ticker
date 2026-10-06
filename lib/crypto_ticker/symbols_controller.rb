# frozen_string_literal: true

module CryptoTicker
  class SymbolsController < ::ApplicationController
    # Base currencies listed on OKX / Binance (USDT pairs) so the client can
    # decide the link and drop coins not listed on either exchange.
    def exchanges
      render json: { okx: CoinCatalog.okx_symbols, binance: CoinCatalog.binance_symbols }
    end
  end
end
