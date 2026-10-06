# frozen_string_literal: true

module CryptoTicker
  # Server-side quotes for stocks and indexes via Stooq (no API key, no CORS).
  class Quotes
    STOOQ_URL = "https://stooq.com/q/l/"
    CACHE_TTL = 60.seconds
    MAX_SYMBOLS = 50
    USER_AGENT = "Mozilla/5.0 (compatible; DiscourseCryptoTicker/1.0)"
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
          STOOQ_URL,
          query: { s: symbol, f: "sd2t2ohlcv", h: "", e: "csv" },
          headers: { "User-Agent" => USER_AGENT },
          connect_timeout: 5,
          read_timeout: 10,
          idempotent: true,
        )
      return nil if response.status != 200

      parse(response.body, symbol)
    rescue StandardError => e
      Rails.logger.warn(
        "discourse-crypto-ticker: stooq #{symbol} failed (#{e.class}: #{e.message})",
      )
      nil
    end

    def parse(body, symbol)
      lines = body.to_s.split(/\r?\n/).reject(&:empty?)
      return nil if lines.size < 2

      # Stooq CSV header: Symbol,Date,Time,Open,High,Low,Close,Volume
      values = lines[1].split(",")
      return nil if values.size < 8

      open = to_f(values[3])
      close = to_f(values[6])
      return nil if close.nil? || close.zero?

      change = (open && !open.zero?) ? ((close - open) / open) * 100.0 : nil

      {
        symbol: symbol,
        name: symbol,
        price: close,
        change: change,
        kind: symbol.start_with?("^") ? "index" : "stock",
      }
    end

    def to_f(value)
      Float(value)
    rescue StandardError
      nil
    end
  end
end
