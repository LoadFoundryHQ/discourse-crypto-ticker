# frozen_string_literal: true

module CryptoTicker
  class StyleSetting
    CLASSIC = "classic"
    DARK = "dark"
    MINIMAL = "minimal"
    CARDS = "cards"

    def self.valid_value?(value)
      values.any? { |entry| entry[:value] == value }
    end

    def self.values
      @values ||= [
        { name: "crypto_ticker.styles.classic", value: CLASSIC },
        { name: "crypto_ticker.styles.dark", value: DARK },
        { name: "crypto_ticker.styles.minimal", value: MINIMAL },
        { name: "crypto_ticker.styles.cards", value: CARDS },
      ]
    end

    def self.translate_names?
      true
    end
  end
end
