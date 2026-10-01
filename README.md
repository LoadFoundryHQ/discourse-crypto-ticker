# discourse-crypto-ticker

A Discourse plugin that adds a **cryptocurrency price ticker** with live prices and 24h change.

- 💰 Live prices + 24h change for the coins you choose.
- 📍 **6 positions**: below the header, above/below the topic list, top/end of a topic, or the left sidebar.
- 🎨 **4 styles**: Classic and Dark (scrolling strips), Minimal (flat, wraps) and Cards (static grid).
- 🧩 **Coin picker**: an admin page with the top 20 coins and a live search of Binance-listed coins.
- 🔗 Every coin links to **Binance**.
- 🆓 Prices from the public **CoinGecko** API — no API key required.
- 📱 Fully responsive; scrolling styles pause on hover.

## Screenshot

> `[ BTC $67,123 +1.23% ]  [ ETH $3,456 -0.45% ]  [ SOL … ]`

## Installation

Add to your `containers/app.yml` (inside `hooks: after_code:`):

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/bitforo/discourse-crypto-ticker.git
```

Then rebuild:

```bash
cd /var/discourse
./launcher rebuild app
```

## Choosing coins

Open **Admin → Plugins → Crypto Ticker** (or `/admin/plugins/crypto-ticker`) and go to the
**Coins** tab: pick from the top 20 by market cap, or search any Binance-listed coin by
symbol or name. Click **Save**.

Leave the selection empty to automatically show the top coins by market cap.

## Settings

Admin → Settings → Plugins (area **Crypto Ticker**):

| Setting | Default | Description |
|---|---|---|
| `crypto_ticker_enabled` | `true` | Enable/disable the ticker. |
| `crypto_ticker_position` | `below-site-header` | Where the ticker is rendered. |
| `crypto_ticker_style` | `classic` | Visual style. |
| `crypto_ticker_top_count` | `10` | How many top coins to show when no coins are selected. |
| `crypto_ticker_show_change` | `true` | Show the 24h percentage change. |

`crypto_ticker_coins` (the selected CoinGecko ids) is **hidden** from Settings because it is
managed from the coin picker page.

### Positions

`below-site-header`, `discovery-list-container-top`, `topic-list-bottom`,
`topic-above-post-stream`, `post-stream-bottom`, `before-sidebar-sections`.

### Styles

`classic`, `dark` (both scrolling) · `minimal`, `cards` (both static).

## Notes

- Prices are fetched **client-side** from the public CoinGecko API and refreshed every 60 s.
  For high-traffic forums, consider moving the fetch server-side to avoid CoinGecko rate limits.
- Every coin links to its **Binance** page.

## License

MIT
