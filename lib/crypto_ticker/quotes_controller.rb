# frozen_string_literal: true

module CryptoTicker
  class QuotesController < ::ApplicationController
    def index
      symbols = Quotes.clean_symbols(params[:symbols])
      render json: Quotes.new(symbols).to_h
    end
  end
end
