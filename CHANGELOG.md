# Changelog

## 1.7.1

- Hide the native (empty) "Settings" tab so only the plugin's own fully-translated "Settings" tab shows.

## 1.7.0

- **Custom "Settings" page** inside the plugin (own tab, **fully translated including titles**): enable ticker, position, style, language and top count. The native (English-titled) site settings are hidden from the panel.
- **Fixed** stocks/indexes not showing in the ticker: the picker saves them pipe-separated (`|`); the ticker now splits on `|` too.

## 1.6.1

- **Fixed**: the admin bundle failed to load because it imported `inject` from `@ember/service` (removed in Ember 7). Now imports `service`. This is why the admin tabs rendered blank.

## 1.6.0

- Admin UI split into **independent tabs**: **Coins**, **Stocks** and **Indexes** now appear next to the automatic **Settings** tab (no more a single "Ticker" page with sub-tabs).
- Added a server-side fallback so a hard refresh on an admin tab renders the SPA instead of 404.

## 1.5.1

- **Fixed the admin picker route** (`Ticker` tab was blank / 404): the route map must live under `assets/javascripts/discourse/` so Discourse registers it as `discourse/…-route-map`.

## 1.5.0

- **Language is now a plugin setting** (`crypto_ticker_language`, in Admin → Settings → Plugins): `Automatic (user's language)`, `English`, `Español` or `Português`. It drives the language of the plugin's options and its coin/stock/index picker.
- **`Crypto ticker show change`** and **`Crypto ticker stocks enabled`** are now **on by default and hidden** from the settings panel.
- **`Crypto ticker stocks`** is now **hidden** (stocks and indexes are chosen from the picker's tabs, no need to type symbols).

## 1.4.0

- **Language selector in the admin picker** (English / Español / Português): switch the plugin UI language on the spot, no need to change your Discourse interface language. The choice is remembered.
- **Localized settings**: descriptions for the plugin site settings (Position, Style, Top count, Show change, Stocks & indexes…) now available in **Spanish and Portuguese** (`server.es.yml`, `server.pt.yml`), plus setting titles and full `client.pt.yml`.

## 1.3.0

- **Admin picker with tabs** (Cripto / Acciones / Índices): choose everything from the UI, no need to type symbols.
  - **Stocks**: search by symbol or name (Yahoo Finance via `/admin/plugins/crypto-ticker/search`), click to add/remove.
  - **Indexes**: curated list (S&P 500, Nasdaq, Dow, DAX, IBEX, Nikkei…), click to toggle.
  - Both saved together with `crypto_ticker_stocks` (`PUT /admin/plugins/crypto-ticker/stocks`).
- OKX affiliate id lowercased to `discourse`.

## 1.2.0

- **Affiliate/monetization is built-in and hidden**: the settings `crypto_ticker_okx_enabled` (default **on**), `crypto_ticker_okx_aff`, `crypto_ticker_okx_url`, `crypto_ticker_tv_url`, `crypto_ticker_binance_aff`, `crypto_ticker_binance_url` and `crypto_ticker_tradingview_aff` are **not shown** in the admin UI and not meant to be edited by users.
- Crypto links → **OKX** by default; a coin **not listed on OKX** but listed on **Binance** links to Binance; a coin listed on **neither** is **not shown** (`/crypto-ticker/exchange-symbols`).

## 1.1.0

- **Stocks & indexes** (behind `crypto_ticker_stocks_enabled`, off by default): quotes via **Yahoo Finance** through a server-side proxy (`/crypto-ticker/quotes`).
- Crypto links use **OKX** only when `crypto_ticker_okx_enabled` is on (off by default → stays on **Binance**); coins not on OKX fall back to Binance. Admins can preview everything with `?crypto_ticker_preview=1`.
- **Affiliate links**: crypto → **OKX** (`crypto_ticker_okx_aff`, `crypto_ticker_okx_url`); coins **not on OKX** fall back to **Binance** (`crypto_ticker_binance_aff`, `crypto_ticker_binance_url`); stocks/indexes → **TradingView** (`crypto_ticker_tradingview_aff`, `crypto_ticker_tv_url`).
- Staff preview via `?crypto_ticker_preview=stocks` (no need to toggle the setting).
- New settings: `crypto_ticker_stocks`, `crypto_ticker_okx_aff`, `crypto_ticker_tradingview_aff`, `crypto_ticker_okx_url`, `crypto_ticker_tv_url`.

## 1.0.0

- Rebranded to **Load Foundry Crypto Ticker** (Load Foundry).
- Moved the repository to `LoadFoundryHQ/discourse-crypto-ticker` (old URL redirects).
- Updated `plugin.rb` metadata, README, locales and license attribution.
- Setting keys keep the `crypto_ticker_*` prefix so existing forums preserve their configuration.

## 0.4.0

- Previous release under the original `bitforo/discourse-crypto-ticker` repository.
