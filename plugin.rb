# frozen_string_literal: true

# name: discourse-crypto-ticker
# about: Load Foundry Crypto Ticker — a cryptocurrency price ticker with 6 positions, 4 styles and a coin picker.
# version: 1.1.1
# authors: Load Foundry (originally by BitForo)
# url: https://github.com/LoadFoundryHQ/discourse-crypto-ticker
# required_version: 3.2.0

enabled_site_setting :crypto_ticker_enabled

# Loaded eagerly: enum site settings must exist before settings are parsed.
require_relative "lib/crypto_ticker/position_setting"
require_relative "lib/crypto_ticker/style_setting"
require_relative "lib/crypto_ticker/coin_catalog"

register_asset "stylesheets/crypto-ticker.scss"
register_asset "stylesheets/crypto-ticker-admin.scss", :admin

register_svg_icon "coins"

add_admin_route "crypto_ticker.title", "discourse-crypto-ticker", use_new_show_route: true

after_initialize do
  require_relative "lib/crypto_ticker/admin_controller"
  require_relative "lib/crypto_ticker/quotes"
  require_relative "lib/crypto_ticker/quotes_controller"
  require_relative "lib/crypto_ticker/symbols_controller"

  Discourse::Application.routes.append do
    scope "/admin/plugins/crypto-ticker", defaults: { format: :json } do
      get "/coins" => "crypto_ticker/admin#coins"
      put "/coins" => "crypto_ticker/admin#update"
    end

    # Public proxy for stocks/indexes quotes (Yahoo Finance).
    get "/crypto-ticker/quotes" => "crypto_ticker/quotes#index", defaults: { format: :json }
    # OKX-listed base currencies (to pick OKX vs Binance link).
    get "/crypto-ticker/okx-symbols" => "crypto_ticker/symbols#okx", defaults: { format: :json }
  end
end
