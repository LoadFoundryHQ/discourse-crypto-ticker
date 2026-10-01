# frozen_string_literal: true

# name: discourse-crypto-ticker
# about: Adds a price ticker for major cryptocurrencies just below the site header.
# version: 0.3.0
# authors: BitForo
# url: https://github.com/bitforo/discourse-crypto-ticker
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

  Discourse::Application.routes.append do
    scope "/admin/plugins/crypto-ticker", defaults: { format: :json } do
      get "/coins" => "crypto_ticker/admin#coins"
      put "/coins" => "crypto_ticker/admin#update"
    end
  end
end
