# frozen_string_literal: true

module CryptoTicker
  class CoinCatalog
    COINGECKO_MARKETS_URL = "https://api.coingecko.com/api/v3/coins/markets"
    BINANCE_PRODUCTS_URL =
      "https://www.binance.com/bapi/asset/v2/public/asset-service/product/get-products"
    CACHE_KEY = "crypto_ticker:coin_catalog"
    CACHE_TTL = 6.hours
    MARKET_LIMIT = 250
    TOP_SIZE = 20
    USER_AGENT = "Mozilla/5.0 (compatible; DiscourseCryptoTicker/0.3)"

    def self.selected_ids
      (SiteSetting.crypto_ticker_coins || "").split(/[|,]/).map(&:strip).reject(&:empty?)
    end

    def to_h
      { selected: self.class.selected_ids, top: catalog.first(TOP_SIZE), coins: catalog }
    end

    def catalog
      Discourse.cache.fetch(CACHE_KEY, expires_in: CACHE_TTL) { build_catalog }
    end

    private

    def build_catalog
      markets = coingecko_markets
      symbols = binance_symbols
      return markets if symbols.empty?

      markets.select { |coin| symbols.key?(coin["symbol"]) }
    end

    def coingecko_markets
      data =
        get_json(
          COINGECKO_MARKETS_URL,
          vs_currency: "usd",
          order: "market_cap_desc",
          per_page: MARKET_LIMIT,
          page: 1,
          sparkline: false,
        )
      return [] unless data.is_a?(Array)

      data.filter_map do |coin|
        id = coin["id"].to_s
        symbol = coin["symbol"].to_s.upcase
        next if id.empty? || symbol.empty?

        { "id" => id, "symbol" => symbol, "name" => coin["name"].to_s }
      end
    end

    def binance_symbols
      data = get_json(BINANCE_PRODUCTS_URL)
      products = data.is_a?(Hash) ? data["data"] : nil
      return {} unless products.is_a?(Array)

      products.each_with_object({}) do |product, memo|
        symbol = product["b"].to_s.upcase
        memo[symbol] = true if symbol.present?
      end
    end

    def get_json(url, params = {})
      response =
        Excon.get(
          url,
          query: params.presence,
          headers: { "Accept" => "application/json", "User-Agent" => USER_AGENT },
          connect_timeout: 5,
          read_timeout: 15,
          idempotent: true,
        )
      return nil if response.status != 200

      JSON.parse(response.body)
    rescue StandardError => e
      Rails.logger.warn(
        "discourse-crypto-ticker: request to #{url} failed (#{e.class}: #{e.message})",
      )
      nil
    end
  end
end
