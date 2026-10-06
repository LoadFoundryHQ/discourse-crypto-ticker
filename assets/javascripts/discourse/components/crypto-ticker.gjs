import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";

const COINGECKO_MARKETS = "https://api.coingecko.com/api/v3/coins/markets";
const CURRENCY = "usd";
const REFRESH_SECONDS = 60;

// Styles that scroll horizontally (marquee). The rest are static.
const MARQUEE_STYLES = ["classic", "dark"];

// Stablecoins can't be paired with themselves on OKX; send them to the signup link.
const STABLECOINS = ["USDT"];

// Referral templates (editable via site settings without touching code).
const DEFAULT_OKX_URL = "https://www.okx.com/trade-spot/{pair}?channelId={aff}";
const DEFAULT_OKX_JOIN = "https://www.okx.com/join/{aff}";
const DEFAULT_TV_URL = "https://es.tradingview.com/symbols/{symbol}/?aff_id={aff}";

// Shared cache (per tab) so the ticker doesn't re-fetch on every navigation when
// it is rendered inside the router outlet (list/topic positions).
let priceCache = { at: 0, data: null };

export default class CryptoTicker extends Component {
  @service siteSettings;
  @service currentUser;

  @tracked prices = null;
  @tracked stocks = null;
  timer = null;
  onVisibility = null;

  constructor() {
    super(...arguments);

    if (!this.enabled) {
      return;
    }

    if (priceCache.data && Date.now() - priceCache.at < REFRESH_SECONDS * 1000) {
      this.prices = priceCache.data;
    } else {
      this.load();
    }

    if (this.stocksEnabled && this.stockSymbols.length) {
      this.loadStocks();
    }

    this.timer = setInterval(() => {
      this.load();
      if (this.stocksEnabled && this.stockSymbols.length) {
        this.loadStocks();
      }
    }, REFRESH_SECONDS * 1000);

    this.onVisibility = () => {
      if (!document.hidden) {
        this.load();
        if (this.stocksEnabled && this.stockSymbols.length) {
          this.loadStocks();
        }
      }
    };
    document.addEventListener("visibilitychange", this.onVisibility);
  }

  willDestroy() {
    super.willDestroy(...arguments);
    clearInterval(this.timer);
    if (this.onVisibility) {
      document.removeEventListener("visibilitychange", this.onVisibility);
    }
  }

  get enabled() {
    return this.siteSettings.crypto_ticker_enabled;
  }

  get style() {
    return this.siteSettings.crypto_ticker_style || "classic";
  }

  get position() {
    return this.siteSettings.crypto_ticker_position || "below-site-header";
  }

  get marquee() {
    return MARQUEE_STYLES.includes(this.style);
  }

  get containerClass() {
    return `crypto-ticker crypto-ticker--${this.style} crypto-ticker--pos-${this.position}`;
  }

  get showChange() {
    return this.siteSettings.crypto_ticker_show_change;
  }

  get ids() {
    return (this.siteSettings.crypto_ticker_coins || "")
      .split(/[|,]/)
      .map((id) => id.trim())
      .filter(Boolean);
  }

  get topCount() {
    return parseInt(this.siteSettings.crypto_ticker_top_count, 10) || 10;
  }

  get stocksEnabled() {
    if (this.siteSettings.crypto_ticker_stocks_enabled) {
      return true;
    }
    // Staff-only preview via ?crypto_ticker_preview=stocks (no need to toggle the setting).
    return (
      !!this.currentUser?.staff &&
      typeof window !== "undefined" &&
      window.location.search.includes("crypto_ticker_preview")
    );
  }

  get stockSymbols() {
    return (this.siteSettings.crypto_ticker_stocks || "")
      .split(/[,\s]+/)
      .map((symbol) => symbol.trim())
      .filter(Boolean);
  }

  get rows() {
    const rows = [...this.cryptoRows, ...this.stockRows];
    return this.marquee ? [...rows, ...rows] : rows;
  }

  get cryptoRows() {
    if (!Array.isArray(this.prices) || !this.prices.length) {
      return [];
    }

    return this.prices.map((coin) => {
      const change = coin?.price_change_percentage_24h;
      const hasChange = typeof change === "number";
      const symbol = (coin?.symbol || "").toUpperCase();
      return {
        symbol,
        url: this.okxUrl(symbol),
        price: this.formatPrice(coin?.current_price),
        change: hasChange ? `${change >= 0 ? "+" : ""}${change.toFixed(2)}%` : "",
        up: !hasChange || change >= 0,
      };
    });
  }

  get stockRows() {
    if (!this.stocksEnabled || !Array.isArray(this.stocks) || !this.stocks.length) {
      return [];
    }

    return this.stocks.map((quote) => {
      const change = quote?.change;
      const hasChange = typeof change === "number";
      return {
        symbol: this.tvSymbol(quote?.symbol || ""),
        url: this.tvUrl(quote?.symbol || ""),
        price: this.formatPrice(quote?.price),
        change: hasChange ? `${change >= 0 ? "+" : ""}${change.toFixed(2)}%` : "",
        up: !hasChange || change >= 0,
      };
    });
  }

  async load() {
    // Don't poll while the tab is in the background.
    if (document.hidden) {
      return;
    }

    try {
      const response = await fetch(this.apiUrl(), {
        headers: { Accept: "application/json" },
      });
      if (!response.ok) {
        throw new Error(`CoinGecko HTTP ${response.status}`);
      }

      const payload = await response.json();
      if (!Array.isArray(payload)) {
        throw new Error("Unexpected CoinGecko response");
      }

      let list = payload;
      if (!this.ids.length) {
        list = list.slice(0, this.topCount);
      }

      this.prices = list;
      priceCache = { at: Date.now(), data: list };
    } catch (error) {
      // Keep the last good data; the ticker stays as-is until the next attempt.
    }
  }

  async loadStocks() {
    try {
      const symbols = encodeURIComponent(this.stockSymbols.join(","));
      const response = await fetch(`/crypto-ticker/quotes?symbols=${symbols}`, {
        headers: { Accept: "application/json" },
      });
      if (!response.ok) {
        throw new Error(`quotes HTTP ${response.status}`);
      }
      const payload = await response.json();
      this.stocks = Array.isArray(payload?.quotes) ? payload.quotes : [];
    } catch (error) {
      // Keep the last good data.
    }
  }

  okxUrl(symbol) {
    const aff = encodeURIComponent(this.siteSettings.crypto_ticker_okx_aff || "");
    const sym = String(symbol).toLowerCase();

    if (STABLECOINS.includes(symbol)) {
      return (DEFAULT_OKX_JOIN).replace("{aff}", aff);
    }

    const template = this.siteSettings.crypto_ticker_okx_url || DEFAULT_OKX_URL;
    return template
      .replace("{pair}", encodeURIComponent(`${sym}-usdt`))
      .replace("{aff}", aff);
  }

  tvSymbol(symbol) {
    return String(symbol)
      .replace(/^\^/, "")
      .replace(/\.(us|uk|de|jp|hk)$/i, "")
      .toUpperCase();
  }

  tvUrl(symbol) {
    const aff = encodeURIComponent(this.siteSettings.crypto_ticker_tradingview_aff || "");
    const template = this.siteSettings.crypto_ticker_tv_url || DEFAULT_TV_URL;
    return template
      .replace("{symbol}", encodeURIComponent(this.tvSymbol(symbol)))
      .replace("{aff}", aff);
  }

  formatPrice(value) {
    const number = Number(value);
    if (!Number.isFinite(number)) {
      return "—";
    }
    const decimals = number >= 1000 ? 0 : number >= 1 ? 2 : number >= 0.001 ? 4 : 6;
    return `$${number.toLocaleString("en-US", { minimumFractionDigits: decimals, maximumFractionDigits: decimals })}`;
  }

  apiUrl() {
    const base = `${COINGECKO_MARKETS}?vs_currency=${CURRENCY}&price_change_percentage=24h&sparkline=false`;
    if (this.ids.length) {
      const ids = this.ids.map((id) => encodeURIComponent(id)).join(",");
      return `${base}&ids=${ids}`;
    }
    return `${base}&order=market_cap_desc&per_page=${this.topCount + 10}&page=1`;
  }

  <template>
    {{#if this.enabled}}
      {{#if this.rows.length}}
        <div class={{this.containerClass}} aria-label={{i18n "crypto_ticker.aria_label"}}>
          <div class="crypto-ticker__track">
            {{#each this.rows as |row|}}
              <a
                class="crypto-ticker__coin"
                href={{row.url}}
                target="_blank"
                rel="noopener noreferrer"
              >
                <span class="crypto-ticker__sym">{{row.symbol}}</span>
                <span class="crypto-ticker__price">{{row.price}}</span>
                {{#if this.showChange}}
                  <span class="crypto-ticker__chg {{if row.up 'up' 'down'}}">{{row.change}}</span>
                {{/if}}
              </a>
            {{/each}}
          </div>
        </div>
      {{/if}}
    {{/if}}
  </template>
}
