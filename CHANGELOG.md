# Changelog

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
