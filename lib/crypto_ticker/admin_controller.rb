# frozen_string_literal: true

module CryptoTicker
  class AdminController < Admin::AdminController
    def coins
      render json: CoinCatalog.new.to_h
    end

    def update
      ids = params[:coins].to_s.split(/[|,]/).map(&:strip).reject(&:empty?).uniq
      SiteSetting.crypto_ticker_coins = ids.join("|")
      render json: { selected: ids }
    end
  end
end
