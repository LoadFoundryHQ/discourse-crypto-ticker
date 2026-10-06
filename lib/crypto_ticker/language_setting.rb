# frozen_string_literal: true

module CryptoTicker
  class LanguageSetting
    AUTO = "auto"
    EN = "en"
    ES = "es"
    PT = "pt"

    def self.valid_value?(value)
      values.any? { |entry| entry[:value] == value }
    end

    def self.values
      @values ||= [
        { name: "crypto_ticker.languages.auto", value: AUTO },
        { name: "crypto_ticker.languages.en", value: EN },
        { name: "crypto_ticker.languages.es", value: ES },
        { name: "crypto_ticker.languages.pt", value: PT },
      ]
    end

    def self.translate_names?
      true
    end
  end
end
