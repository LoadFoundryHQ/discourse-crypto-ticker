# frozen_string_literal: true

module CryptoTicker
  class AdminController < Admin::AdminController
    # CoinGecko ids are lowercase slugs (a-z, 0-9 and dashes).
    COIN_ID = /\A[a-z0-9-]+\z/

    def coins
      render json: CoinCatalog.new.to_h
    end

    def update
      ids =
        params[:coins]
          .to_s
          .split(/[|,]/)
          .map { |id| id.to_s.strip.downcase }
          .select { |id| id.match?(COIN_ID) }
          .uniq

      SiteSetting.crypto_ticker_coins = ids.join("|")
      render json: { selected: ids }
    end
  end
end
