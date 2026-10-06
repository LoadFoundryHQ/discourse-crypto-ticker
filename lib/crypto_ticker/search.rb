# frozen_string_literal: true

module CryptoTicker
  # Stock/ETF/index search via Yahoo Finance (server-side, cached by caller).
  class Search
    URL = "https://query1.finance.yahoo.com/v1/finance/search"
    TYPES = %w[EQUITY ETF INDEX MUTUALFUND].freeze
    USER_AGENT = "Mozilla/5.0 (compatible; DiscourseCryptoTicker/1.2)"

    def initialize(query)
      @query = query
    end

    def results
      data = get
      quotes = data.is_a?(Hash) ? data["quotes"] : nil
      return [] unless quotes.is_a?(Array)

      quotes.filter_map do |quote|
        type = quote["quoteType"].to_s
        next unless TYPES.include?(type)

        symbol = quote["symbol"].to_s
        next if symbol.empty?

        {
          "symbol" => symbol,
          "name" => quote["shortname"] || quote["longname"] || symbol,
          "type" => type.downcase,
        }
      end
    end

    private

    def get
      response =
        Excon.get(
          URL,
          query: { q: @query, quotesCount: 20, newsCount: 0 },
          headers: { "Accept" => "application/json", "User-Agent" => USER_AGENT },
          connect_timeout: 5,
          read_timeout: 10,
          idempotent: true,
        )
      return nil if response.status != 200

      JSON.parse(response.body)
    rescue StandardError => e
      Rails.logger.warn(
        "discourse-crypto-ticker: yahoo search failed (#{e.class}: #{e.message})",
      )
      nil
    end
  end
end
