import Controller from "@ember/controller";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { later } from "@ember/runloop";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class CryptoTickerPickerController extends Controller {
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
