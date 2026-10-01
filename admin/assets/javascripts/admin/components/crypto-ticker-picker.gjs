import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { i18n } from "discourse-i18n";

const CoinButton = <template>
  <button
    type="button"
    class="crypto-ticker-picker__coin
      {{if @coin.selected 'is-selected'}}"
    {{on "click" (fn @controller.toggle @coin.id)}}
  >
    <span class="crypto-ticker-picker__coin-symbol">{{@coin.symbol}}</span>
    <span class="crypto-ticker-picker__coin-name">{{@coin.name}}</span>
  </button>
</template>;

export default <template>
  <div class="crypto-ticker-picker">
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
        <CoinButton @coin={{coin}} @controller={{@controller}} />
      {{/each}}
    </div>

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
