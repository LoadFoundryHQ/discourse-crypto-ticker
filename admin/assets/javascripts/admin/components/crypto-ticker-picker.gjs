import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { i18n } from "discourse-i18n";

const CoinButton = <template>
  <button
    type="button"
    class="crypto-ticker-picker__coin {{if @item.selected 'is-selected'}}"
    {{on "click" (fn @controller.toggle @item.id)}}
  >
    <span class="crypto-ticker-picker__coin-symbol">{{@item.symbol}}</span>
    <span class="crypto-ticker-picker__coin-name">{{@item.name}}</span>
  </button>
</template>;

const StockButton = <template>
  <button
    type="button"
    class="crypto-ticker-picker__coin {{if @item.selected 'is-selected'}}"
    {{on "click" (fn @controller.toggleStock @item.symbol)}}
  >
    <span class="crypto-ticker-picker__coin-symbol">{{@item.symbol}}</span>
    <span class="crypto-ticker-picker__coin-name">{{@item.name}}</span>
  </button>
</template>;

const MarketBadge = <template>
  <span class="crypto-ticker-picker__badge">
    {{@item.symbol}}
    <button
      type="button"
      class="crypto-ticker-picker__badge-remove"
      {{on "click" (fn @controller.toggleStock @item.symbol)}}
    >×</button>
  </span>
</template>;

export default <template>
  <div class="crypto-ticker-picker">
    <div class="crypto-ticker-picker__tabs">
      <button
        type="button"
        class="btn {{if (eq @controller.tab 'crypto') 'btn-primary'}}"
        {{on "click" (fn @controller.setTab "crypto")}}
      >{{i18n "crypto_ticker.admin.tab_crypto"}}</button>
      <button
        type="button"
        class="btn {{if (eq @controller.tab 'stocks') 'btn-primary'}}"
        {{on "click" (fn @controller.setTab "stocks")}}
      >{{i18n "crypto_ticker.admin.tab_stocks"}}</button>
      <button
        type="button"
        class="btn {{if (eq @controller.tab 'indexes') 'btn-primary'}}"
        {{on "click" (fn @controller.setTab "indexes")}}
      >{{i18n "crypto_ticker.admin.tab_indexes"}}</button>
    </div>

    {{#if (eq @controller.tab "crypto")}}
      <p class="crypto-ticker-picker__help">
        {{i18n "crypto_ticker.admin.help"}}
      </p>

      <div class="crypto-ticker-picker__selected">
        {{#if @controller.selectedCoins.length}}
          {{#each @controller.selectedCoins as |coin|}}
            <span class="crypto-ticker-picker__badge">
              {{coin.symbol}}
              <button
                type="button"
                class="crypto-ticker-picker__badge-remove"
                {{on "click" (fn @controller.toggle coin.id)}}
              >×</button>
            </span>
          {{/each}}
          <button
            type="button"
            class="btn btn-small crypto-ticker-picker__clear"
            {{on "click" @controller.clear}}
          >
            {{i18n "crypto_ticker.admin.empty"}}
          </button>
        {{else}}
          <span class="crypto-ticker-picker__empty">
            {{i18n "crypto_ticker.admin.empty"}}
          </span>
        {{/if}}
      </div>

      <input
        type="search"
        class="crypto-ticker-picker__search"
        placeholder={{i18n "crypto_ticker.admin.search_placeholder"}}
        value={{@controller.query}}
        {{on "input" @controller.updateQuery}}
      />

      <div class="crypto-ticker-picker__grid">
        {{#each @controller.results as |coin|}}
          <CoinButton @item={{coin}} @controller={{@controller}} />
        {{/each}}
      </div>
    {{else if (eq @controller.tab "stocks")}}
      <p class="crypto-ticker-picker__help">
        {{i18n "crypto_ticker.admin.stocks_help"}}
      </p>

      <div class="crypto-ticker-picker__selected">
        {{#if @controller.stockSelected.length}}
          {{#each @controller.stockSelected as |item|}}
            <MarketBadge @item={{item}} @controller={{@controller}} />
          {{/each}}
        {{else}}
          <span class="crypto-ticker-picker__empty">
            {{i18n "crypto_ticker.admin.none_selected"}}
          </span>
        {{/if}}
      </div>

      <input
        type="search"
        class="crypto-ticker-picker__search"
        placeholder={{i18n "crypto_ticker.admin.stocks_search"}}
        value={{@controller.stockQuery}}
        {{on "input" @controller.updateStockQuery}}
      />

      <div class="crypto-ticker-picker__grid">
        {{#if @controller.searching}}
          <span class="crypto-ticker-picker__empty">
            {{i18n "crypto_ticker.admin.searching"}}
          </span>
        {{else}}
          {{#each @controller.stockResultsWithState as |item|}}
            <StockButton @item={{item}} @controller={{@controller}} />
          {{/each}}
        {{/if}}
      </div>
    {{else}}
      <p class="crypto-ticker-picker__help">
        {{i18n "crypto_ticker.admin.indexes_help"}}
      </p>

      <div class="crypto-ticker-picker__selected">
        {{#if @controller.stockSelected.length}}
          {{#each @controller.stockSelected as |item|}}
            <MarketBadge @item={{item}} @controller={{@controller}} />
          {{/each}}
        {{else}}
          <span class="crypto-ticker-picker__empty">
            {{i18n "crypto_ticker.admin.none_selected"}}
          </span>
        {{/if}}
      </div>

      <div class="crypto-ticker-picker__grid">
        {{#each @controller.indexList as |item|}}
          <StockButton @item={{item}} @controller={{@controller}} />
        {{/each}}
      </div>
    {{/if}}

    <div class="crypto-ticker-picker__actions">
      <button
        type="button"
        class="btn btn-primary"
        disabled={{@controller.saving}}
        {{on "click" @controller.save}}
      >
        {{#if @controller.saving}}
          {{i18n "crypto_ticker.admin.saving"}}
        {{else}}
          {{i18n "crypto_ticker.admin.save"}}
        {{/if}}
      </button>
      {{#if @controller.saved}}
        <span class="crypto-ticker-picker__saved">
          {{i18n "crypto_ticker.admin.saved"}}
        </span>
      {{/if}}
    </div>
  </div>
</template>;
