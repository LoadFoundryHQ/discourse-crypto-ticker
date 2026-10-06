import Controller from "@ember/controller";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import { later } from "@ember/runloop";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

const PICKER_I18N = {
  en: {
    tab_crypto: "Crypto",
    tab_stocks: "Stocks",
    tab_indexes: "Indexes",
    help: "Choose the coins shown in the ticker. If you leave it empty, the top 10 by market capitalization are shown automatically. Only coins listed on OKX can be added.",
    empty: "No coins selected — the top 10 by market cap will be shown.",
    search_placeholder: "Search a coin by symbol or name…",
    none_selected: "Nothing selected yet.",
    stocks_help: "Search for stocks by symbol or name and add them to the ticker.",
    stocks_search: "Search a stock (e.g. AAPL, Tesla…)",
    indexes_help: "Pick the indexes shown in the ticker.",
    searching: "Searching…",
    save: "Save",
    saving: "Saving…",
    saved: "Saved! Reload the page to see the changes.",
  },
  es: {
    tab_crypto: "Cripto",
    tab_stocks: "Acciones",
    tab_indexes: "Índices",
    help: "Elige las monedas que se muestran en el ticker. Si lo dejas vacío, se muestran automáticamente las 10 principales por capitalización. Solo se pueden añadir monedas listadas en OKX.",
    empty: "Sin monedas seleccionadas — se mostrarán las 10 principales por capitalización.",
    search_placeholder: "Busca una moneda por símbolo o nombre…",
    none_selected: "Nada seleccionado todavía.",
    stocks_help: "Busca acciones por símbolo o nombre y añádelas al ticker.",
    stocks_search: "Busca una acción (p. ej. AAPL, Tesla…)",
    indexes_help: "Elige los índices que se muestran en el ticker.",
    searching: "Buscando…",
    save: "Guardar",
    saving: "Guardando…",
    saved: "¡Guardado! Recarga la página para ver los cambios.",
  },
  pt: {
    tab_crypto: "Cripto",
    tab_stocks: "Ações",
    tab_indexes: "Índices",
    help: "Escolha as moedas exibidas no ticker. Se deixar vazio, as 10 principais por valor de mercado são exibidas automaticamente. Só é possível adicionar moedas listadas na OKX.",
    empty: "Nenhuma moeda selecionada — as 10 principais por valor de mercado serão exibidas.",
    search_placeholder: "Buscar uma moeda por símbolo ou nome…",
    none_selected: "Nada selecionado ainda.",
    stocks_help: "Busque ações por símbolo ou nome e adicione-as ao ticker.",
    stocks_search: "Buscar uma ação (ex.: AAPL, Tesla…)",
    indexes_help: "Escolha os índices exibidos no ticker.",
    searching: "Buscando…",
    save: "Salvar",
    saving: "Salvando…",
    saved: "Salvo! Recarregue a página para ver as alterações.",
  },
};

function interfaceLocale() {
  const html = (document.documentElement.getAttribute("lang") || "en")
    .slice(0, 2)
    .toLowerCase();
  return PICKER_I18N[html] ? html : "en";
}

export default class CryptoTickerPickerController extends Controller {
  @service siteSettings;

  @tracked allCoins = [];
  @tracked topCoins = [];
  @tracked selectedIds = [];
  @tracked query = "";

  @tracked indexes = [];
  @tracked selectedStocks = [];
  @tracked stockQuery = "";
  @tracked stockResults = [];
  @tracked searching = false;

  @tracked tab = "crypto";
  @tracked saving = false;
  @tracked saved = false;

  get locale() {
    const setting = this.siteSettings.crypto_ticker_language;
    if (setting && setting !== "auto" && PICKER_I18N[setting]) {
      return setting;
    }
    return interfaceLocale();
  }

  get strings() {
    return PICKER_I18N[this.locale] || PICKER_I18N.en;
  }

  get results() {
    const term = this.query.trim().toLowerCase();
    const coins = term
      ? this.allCoins.filter(
          (coin) =>
            coin.symbol.toLowerCase().includes(term) ||
            coin.name.toLowerCase().includes(term)
        )
      : this.topCoins;

    const selected = new Set(this.selectedIds);
    return coins
      .slice(0, 60)
      .map((coin) => ({ ...coin, selected: selected.has(coin.id) }));
  }

  get selectedCoins() {
    const byId = {};
    this.allCoins.forEach((coin) => (byId[coin.id] = coin));
    return this.selectedIds.map(
      (id) => byId[id] || { id, symbol: id.toUpperCase(), name: id }
    );
  }

  get stockSelected() {
    const known = {};
    this.indexes.forEach((index) => (known[index.symbol] = index));
    return this.selectedStocks.map(
      (symbol) => known[symbol] || { symbol, name: symbol }
    );
  }

  get stockResultsWithState() {
    const selected = new Set(this.selectedStocks);
    return this.stockResults.map((result) => ({
      ...result,
      selected: selected.has(result.symbol),
    }));
  }

  get indexList() {
    const selected = new Set(this.selectedStocks);
    return this.indexes.map((index) => ({
      ...index,
      selected: selected.has(index.symbol),
    }));
  }

  get stockSelectedCount() {
    return this.selectedStocks.length;
  }

  @action
  setTab(tab) {
    this.tab = tab;
    this.saved = false;
  }

  @action
  updateQuery(event) {
    this.query = event.target.value;
    this.saved = false;
  }

  @action
  toggle(id) {
    this.saved = false;
    if (this.selectedIds.includes(id)) {
      this.selectedIds = this.selectedIds.filter((coinId) => coinId !== id);
    } else {
      this.selectedIds = [...this.selectedIds, id];
    }
  }

  @action
  clear() {
    this.saved = false;
    this.selectedIds = [];
  }

  @action
  updateStockQuery(event) {
    this.stockQuery = event.target.value;
    this.saved = false;

    if (this.stockQuery.trim().length < 1) {
      this.stockResults = [];
      return;
    }
    later(this, () => this.searchStocks(), 350);
  }

  async searchStocks() {
    const term = this.stockQuery.trim();
    if (term.length < 1) {
      return;
    }
    this.searching = true;
    try {
      const data = await ajax("/admin/plugins/crypto-ticker/search.json", {
        data: { q: term },
      });
      this.stockResults = data.results || [];
    } catch (error) {
      this.stockResults = [];
    } finally {
      this.searching = false;
    }
  }

  @action
  toggleStock(symbol) {
    this.saved = false;
    if (this.selectedStocks.includes(symbol)) {
      this.selectedStocks = this.selectedStocks.filter((s) => s !== symbol);
    } else {
      this.selectedStocks = [...this.selectedStocks, symbol];
    }
  }

  @action
  async save() {
    this.saving = true;
    try {
      await ajax("/admin/plugins/crypto-ticker/coins", {
        type: "PUT",
        data: { coins: this.selectedIds.join("|") },
      });
      await ajax("/admin/plugins/crypto-ticker/stocks", {
        type: "PUT",
        data: { stocks: this.selectedStocks.join("|") },
      });
      this.saved = true;
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.saving = false;
    }
  }
}
