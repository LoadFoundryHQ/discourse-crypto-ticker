import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";

const COINGECKO_MARKETS = "https://api.coingecko.com/api/v3/coins/markets";
const CURRENCY = "usd";
const REFRESH_SECONDS = 60;
const BINANCE_BASE = "https://www.binance.com/price/";

// Referral code baked into every Binance link (change here, globally).
const BINANCE_REFERRAL = "discourse";

// Styles that scroll horizontally (marquee). The rest are static.
const MARQUEE_STYLES = ["classic", "dark"];

// Binance price-page slugs (symbol -> slug). Binance doesn't use the raw ticker,
// and CoinGecko's id/name don't always match either (e.g. USDC -> usd-coin).
// Anything not listed falls back to the slugified coin name.
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

// Coins shown by CoinGecko's market cap ranking but WITHOUT an official Binance
// page (would link to a non-existent Binance URL). Excluded from the top list.
const BINANCE_EXCLUDE = ["FIGR_HELOC"];

export default class CryptoTicker extends Component {
  @service siteSettings;

  @tracked prices = null;
  @tracked failed = false;
  timer = null;

  constructor() {
    super(...arguments);
    if (this.enabled) {
      this.load();
      this.timer = setInterval(() => this.load(), REFRESH_SECONDS * 1000);
    }
  }

  willDestroy() {
    super.willDestroy(...arguments);
    if (this.timer) {
      clearInterval(this.timer);
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

  get binanceBase() {
    return BINANCE_BASE;
  }

  get rows() {
    if (!this.prices) {
      return [];
    }
    const formatted = this.prices.map((coin) => {
      const change = coin.price_change_percentage_24h;
      const hasChange = typeof change === "number";
      const symbol = (coin.symbol || "").toUpperCase();
      return {
        symbol,
        url: this.binanceUrl(this.binanceSlug(coin)),
        price: this.formatPrice(coin.current_price),
        change: hasChange ? `${change >= 0 ? "+" : ""}${change.toFixed(2)}%` : "",
        up: !hasChange || change >= 0,
      };
    });
    return this.marquee ? [...formatted, ...formatted] : formatted;
  }

  async load() {
    try {
      const response = await fetch(this.apiUrl(), {
        headers: { Accept: "application/json" },
      });
      if (!response.ok) {
        throw new Error(`CoinGecko HTTP ${response.status}`);
      }
      let list = await response.json();
      if (!this.ids.length) {
        list = list
          .filter((coin) => !BINANCE_EXCLUDE.includes((coin.symbol || "").toUpperCase()))
          .slice(0, this.topCount);
      }
      this.prices = list;
      this.failed = false;
    } catch (error) {
      this.failed = true;
    }
  }

  binanceUrl(slug) {
    return `${this.binanceBase}${slug}?ref=${BINANCE_REFERRAL}`;
  }

  binanceSlug(coin) {
    const symbol = (coin.symbol || "").toUpperCase();
    return BINANCE_SLUGS[symbol] || this.slugify(coin.name || coin.symbol || symbol);
  }

  slugify(name) {
    return name
      .toLowerCase()
      .trim()
      .replace(/\s+/g, "-")
      .replace(/[^a-z0-9-]/g, "");
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
    const base = `${COINGECKO_MARKETS}?vs_currency=${this.currency}&price_change_percentage=24h&sparkline=false`;
    if (this.ids.length) {
      return `${base}&ids=${this.ids.join(",")}`;
    }
    return `${base}&order=market_cap_desc&per_page=${this.topCount + 10}&page=1`;
  }

  get currency() {
    return CURRENCY;
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
