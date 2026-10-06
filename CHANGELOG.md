# Changelog

## 1.1.0

- **Stocks & indexes** (behind `crypto_ticker_stocks_enabled`, off by default): quotes via **Stooq** through a server-side proxy (`/crypto-ticker/quotes`).
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
