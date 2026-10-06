# frozen_string_literal: true

require "cgi"

module CryptoTicker
  # Server-side quotes for stocks and indexes via Yahoo Finance (no API key, no CORS).
  class Quotes
    YAHOO_URL = "https://query1.finance.yahoo.com/v8/finance/chart/"
    CACHE_TTL = 60.seconds
    MAX_SYMBOLS = 50
    USER_AGENT = "Mozilla/5.0 (compatible; DiscourseCryptoTicker/1.1)"
    SYMBOL = /\A[\^a-z0-9.\-]{1,20}\z/i

    def self.clean_symbols(raw)
      raw
        .to_s
        .split(/[,\s]+/)
        .map(&:strip)
        .select { |symbol| symbol.match?(SYMBOL) }
        .uniq
        .first(MAX_SYMBOLS)
    end

    def initialize(symbols)
      @symbols = symbols
    end

    def to_h
      { quotes: @symbols.filter_map { |symbol| quote(symbol) } }
    end

    private

    def quote(symbol)
      key = "crypto_ticker:quote:#{symbol}"
      cached = Discourse.cache.read(key)
      return cached if cached

      result = fetch(symbol)
      Discourse.cache.write(key, result, expires_in: CACHE_TTL) if result
      result
    end

    def fetch(symbol)
      response =
        Excon.get(
          "#{YAHOO_URL}#{CGI.escape(symbol)}",
          query: { interval: "1d", range: "1d" },
          headers: { "Accept" => "application/json", "User-Agent" => USER_AGENT },
          connect_timeout: 5,
          read_timeout: 10,
          idempotent: true,
        )
      return nil if response.status != 200

      parse(response.body, symbol)
    rescue StandardError => e
      Rails.logger.warn(
        "discourse-crypto-ticker: yahoo #{symbol} failed (#{e.class}: #{e.message})",
      )
      nil
    end

    def parse(body, symbol)
      data = JSON.parse(body)
      meta = data.dig("chart", "result", 0, "meta")
      return nil unless meta.is_a?(Hash)

      price = meta["regularMarketPrice"]
      return nil if price.nil?

      {
        symbol: symbol,
        name: meta["shortName"] || meta["symbol"] || symbol,
        price: price.to_f,
        change: meta["regularMarketChangePercent"],
        kind: symbol.start_with?("^") ? "index" : "stock",
      }
    end
  end
end
