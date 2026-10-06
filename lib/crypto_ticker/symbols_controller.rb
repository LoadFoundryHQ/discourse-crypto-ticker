# frozen_string_literal: true

module CryptoTicker
  class SymbolsController < ::ApplicationController
    # Base currencies listed on OKX (USDT pairs) so the client can decide the link.
    def okx
      render json: { symbols: CoinCatalog.okx_symbols }
    end
  end
end
