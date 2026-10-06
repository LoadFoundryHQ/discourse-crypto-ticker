# frozen_string_literal: true

module CryptoTicker
  class CoinCatalog
    COINGECKO_MARKETS_URL = "https://api.coingecko.com/api/v3/coins/markets"
    OKX_INSTRUMENTS_URL = "https://www.okx.com/api/v5/public/instruments"
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
      cached = Discourse.cache.read(CACHE_KEY)
      return cached if cached.present?

      # Never cache an empty catalog: a transient upstream failure would keep the
      # coin picker empty for the whole TTL.
      built = build_catalog
      Discourse.cache.write(CACHE_KEY, built, expires_in: CACHE_TTL) if built.present?
      built
    end

    private

    def build_catalog
      markets = coingecko_markets
      symbols = okx_symbols
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

    def okx_symbols
      data = get_json(OKX_INSTRUMENTS_URL, instType: "SPOT")
      products = data.is_a?(Hash) ? data["data"] : nil
      return {} unless products.is_a?(Array)

      products.each_with_object({}) do |product, memo|
        next unless product["quoteCcy"].to_s == "USDT"
        next unless product["state"].to_s == "live"

        base = product["baseCcy"].to_s.upcase
        memo[base] = true if base.present?
      end
    end

    def get_json(url, params = {})
      response =
        Excon.get(
          url,
          query: params.presence,
          headers: { "Accept" => "application/json", "User-Agent" => USER_AGENT },
          connect_timeout: 5,
          read_timeout: 10,
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
