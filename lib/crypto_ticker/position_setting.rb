# frozen_string_literal: true

module CryptoTicker
  class PositionSetting
    HEADER = "below-site-header"
    TOPIC_LIST_TOP = "discovery-list-container-top"
    TOPIC_LIST_BOTTOM = "topic-list-bottom"
    TOPIC_TOP = "topic-above-post-stream"
    TOPIC_BOTTOM = "post-stream-bottom"
    SIDEBAR = "before-sidebar-sections"

    def self.valid_value?(value)
      values.any? { |entry| entry[:value] == value }
    end

    def self.values
      @values ||= [
        { name: "crypto_ticker.positions.header", value: HEADER },
        { name: "crypto_ticker.positions.topic_list_top", value: TOPIC_LIST_TOP },
        { name: "crypto_ticker.positions.topic_list_bottom", value: TOPIC_LIST_BOTTOM },
        { name: "crypto_ticker.positions.topic_top", value: TOPIC_TOP },
        { name: "crypto_ticker.positions.topic_bottom", value: TOPIC_BOTTOM },
        { name: "crypto_ticker.positions.sidebar", value: SIDEBAR },
      ]
    end

    def self.translate_names?
      true
    end
  end
end
