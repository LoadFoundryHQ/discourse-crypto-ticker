import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";

const COINGECKO_MARKETS = "https://api.coingecko.com/api/v3/coins/markets";
const CURRENCY = "usd";
const REFRESH_SECONDS = 60;

// Styles that scroll horizontally (marquee). The rest are static.
const MARQUEE_STYLES = ["classic", "dark"];

// Referral templates (fixed by Load Foundry, editable via hidden site settings).
const DEFAULT_OKX_URL = "https://www.okx.com/trade-spot/{pair}?channelId={aff}";
const DEFAULT_BINANCE_URL = "https://www.binance.com/price/{slug}?ref={aff}";
const DEFAULT_TV_URL = "https://es.tradingview.com/symbols/{symbol}/?aff_id={aff}";

// Binance price-page slugs (symbol -> slug), used only for coins NOT on OKX.
const BINANCE_SLUGS = {
  BTC: "bitcoin",
  ETH: "ethereum",
  USDT: "tether",
  USDC: "usd-coin",
  BNB: "bnb",
  SOL: "solana",
  XRP: "xrp",
  DOGE: "dogecoin",
  ADA: "cardano",
  TRX: "tron",
  TON: "toncoin",
  AVAX: "avalanche",
  LINK: "chainlink",
  DOT: "polkadot",
  MATIC: "polygon",
  POL: "polygon-ecosystem-token",
  LTC: "litecoin",
  BCH: "bitcoin-cash",
  SHIB: "shiba-inu",
  XLM: "stellar",
  ATOM: "cosmos",
  UNI: "uniswap",
  ETC: "ethereum-classic",
  FIL: "filecoin",
  APT: "aptos",
  ARB: "arbitrum",
  OP: "optimism",
  NEAR: "near-protocol",
  ICP: "internet-computer",
  HBAR: "hedera-hashgraph",
  ZEC: "zcash",
};

// TradingView symbol overrides for common indexes (Yahoo symbol -> TradingView symbol).
const TV_SYMBOLS = {
  "^GSPC": "SPX",
  "^IXIC": "IXIC",
  "^DJI": "DJI",
  "^FTSE": "UKX",
  "^N225": "NI225",
  "^GDAXI": "DAX",
  "^FCHI": "CAC40",
  "^IBEX": "IBEX35",
};

// Shared caches (per tab) so the ticker doesn't re-fetch on every navigation
// when it is rendered inside the router outlet (list/topic positions).
let priceCache = { at: 0, data: null };
let exchangeCache = null;

export default class CryptoTicker extends Component {
  @service siteSettings;
  @service currentUser;

  @tracked prices = null;
  @tracked stocks = null;
  @tracked exchangeSymbols = null;
  timer = null;
  onVisibility = null;

  constructor() {
    super(...arguments);

    if (!this.enabled) {
      return;
    }

    if (exchangeCache) {
      this.exchangeSymbols = exchangeCache;
    } else {
      this.loadExchanges();
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

  get preview() {
    return (
      !!this.currentUser?.staff &&
      typeof window !== "undefined" &&
      window.location.search.includes("crypto_ticker_preview")
    );
  }

  get okxEnabled() {
    return this.siteSettings.crypto_ticker_okx_enabled || this.preview;
  }

  get stocksEnabled() {
    return this.siteSettings.crypto_ticker_stocks_enabled || this.preview;
  }

  get stockSymbols() {
    const configured = (this.siteSettings.crypto_ticker_stocks || "")
      .split(/[,\s]+/)
      .map((symbol) => symbol.trim())
      .filter(Boolean);

    if (configured.length) {
      return configured;
    }

    return this.preview ? ["AAPL", "MSFT", "^GSPC", "^IXIC", "^DJI"] : [];
  }

  get rows() {
    const rows = [...this.cryptoRows, ...this.stockRows];
    return this.marquee ? [...rows, ...rows] : rows;
  }

  get cryptoRows() {
    if (!Array.isArray(this.prices) || !this.prices.length) {
      return [];
    }

    return this.prices
      .filter((coin) => this.listed(coin?.symbol))
      .map((coin) => {
        const change = coin?.price_change_percentage_24h;
        const hasChange = typeof change === "number";
        const symbol = (coin?.symbol || "").toUpperCase();
        return {
          symbol,
          url: this.cryptoUrl(coin, symbol),
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

  // A coin is shown only if it is listed on OKX or Binance (once the lists load).
  listed(symbol) {
    const okx = this.exchangeSymbols?.okx;
    const binance = this.exchangeSymbols?.binance;
    if (!Array.isArray(okx) && !Array.isArray(binance)) {
      return true;
    }
    const sym = String(symbol || "").toUpperCase();
    return (Array.isArray(okx) && okx.includes(sym)) || (Array.isArray(binance) && binance.includes(sym));
  }

  // OKX by default; Binance only when the coin is not listed on OKX.
  cryptoUrl(coin, symbol) {
    const sym = String(symbol || "").toUpperCase();
    const okx = this.exchangeSymbols?.okx;
    const onOkx = !Array.isArray(okx) || okx.includes(sym);
    if (this.okxEnabled && onOkx) {
      return this.okxUrl(sym);
    }
    return this.binanceUrl(coin);
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
        list = list.slice(0, this.topCount + 10);
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

  async loadExchanges() {
    try {
      const response = await fetch("/crypto-ticker/exchange-symbols", {
        headers: { Accept: "application/json" },
      });
      if (!response.ok) {
        throw new Error(`exchange-symbols HTTP ${response.status}`);
      }
      const payload = await response.json();
      exchangeCache = {
        okx: Array.isArray(payload?.okx) ? payload.okx : [],
        binance: Array.isArray(payload?.binance) ? payload.binance : [],
      };
    } catch (error) {
      exchangeCache = { okx: [], binance: [] };
    }
    this.exchangeSymbols = exchangeCache;
  }

  okxUrl(symbol) {
    const aff = encodeURIComponent(this.siteSettings.crypto_ticker_okx_aff || "");
    const template = this.siteSettings.crypto_ticker_okx_url || DEFAULT_OKX_URL;
    return template
      .replace("{pair}", encodeURIComponent(`${String(symbol).toLowerCase()}-usdt`))
      .replace("{aff}", aff);
  }

  binanceUrl(coin) {
    const aff = encodeURIComponent(this.siteSettings.crypto_ticker_binance_aff || "");
    const template = this.siteSettings.crypto_ticker_binance_url || DEFAULT_BINANCE_URL;
    return template
      .replace("{slug}", encodeURIComponent(this.binanceSlug(coin)))
      .replace("{aff}", aff);
  }

  binanceSlug(coin) {
    const symbol = (coin?.symbol || "").toUpperCase();
    return BINANCE_SLUGS[symbol] || this.slugify(coin?.name || coin?.symbol || symbol);
  }

  slugify(name) {
    return String(name)
      .toLowerCase()
      .trim()
      .replace(/\s+/g, "-")
      .replace(/[^a-z0-9-]/g, "");
  }

  tvSymbol(symbol) {
    const raw = String(symbol).toUpperCase();
    if (TV_SYMBOLS[raw]) {
      return TV_SYMBOLS[raw];
    }
    return raw.replace(/^\^/, "").replace(/\.(us|uk|de|jp|hk)$/i, "");
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
    return `${base}&order=market_cap_desc&per_page=${this.topCount + 20}&page=1`;
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
