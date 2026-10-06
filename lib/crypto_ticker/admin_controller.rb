# frozen_string_literal: true

module CryptoTicker
  class AdminController < Admin::AdminController
    # CoinGecko ids are lowercase slugs (a-z, 0-9 and dashes).
    COIN_ID = /\A[a-z0-9-]+\z/
    # Yahoo symbols: stocks (AAPL), indexes (^GSPC), classes (BRK-B).
    MARKET_SYMBOL = /\A[\^a-z0-9.\-]{1,20}\z/i

    INDEXES = [
      { "symbol" => "^GSPC", "name" => "S&P 500" },
      { "symbol" => "^IXIC", "name" => "Nasdaq Composite" },
      { "symbol" => "^NDX", "name" => "Nasdaq 100" },
      { "symbol" => "^DJI", "name" => "Dow Jones Industrial Average" },
      { "symbol" => "^RUT", "name" => "Russell 2000" },
      { "symbol" => "^VIX", "name" => "CBOE Volatility Index" },
      { "symbol" => "^FTSE", "name" => "FTSE 100" },
      { "symbol" => "^GDAXI", "name" => "DAX" },
      { "symbol" => "^FCHI", "name" => "CAC 40" },
      { "symbol" => "^IBEX", "name" => "IBEX 35" },
      { "symbol" => "^STOXX50E", "name" => "Euro Stoxx 50" },
      { "symbol" => "^N225", "name" => "Nikkei 225" },
      { "symbol" => "^HSI", "name" => "Hang Seng" },
      { "symbol" => "^KS11", "name" => "KOSPI" },
      { "symbol" => "^AXJO", "name" => "S&P/ASX 200" },
      { "symbol" => "^BSESN", "name" => "BSE Sensex" },
      { "symbol" => "^MXX", "name" => "IPC México" },
      { "symbol" => "^BVSP", "name" => "Ibovespa" },
    ].freeze

    def coins
      render json: CoinCatalog.new.to_h.merge(
        "indexes" => INDEXES,
        "selected_stocks" => selected_stocks,
      )
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

    def update_stocks
      symbols =
        params[:stocks]
          .to_s
          .split(/[|,\s]+/)
          .map(&:strip)
          .select { |symbol| symbol.match?(MARKET_SYMBOL) }
          .uniq

      SiteSetting.crypto_ticker_stocks = symbols.join("|")
      render json: { selected: symbols }
    end

    def search
      query = params[:q].to_s.strip
      return render json: { results: [] } if query.length < 1

      cache_key = "crypto_ticker:search:#{query.downcase}"
      results = Discourse.cache.read(cache_key)
      if results.nil?
        results = Search.new(query).results
        Discourse.cache.write(cache_key, results, expires_in: 1.hour) if results.present?
      end
      render json: { results: results || [] }
    end

    private

    def selected_stocks
      (SiteSetting.crypto_ticker_stocks || "")
        .split(/[|,\s]+/)
        .map(&:strip)
        .reject(&:empty?)
    end
  end
end
