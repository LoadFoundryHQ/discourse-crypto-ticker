import Controller from "@ember/controller";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class CryptoTickerPickerController extends Controller {
  @tracked allCoins = [];
  @tracked topCoins = [];
  @tracked selectedIds = [];
  @tracked query = "";
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
  async save() {
    this.saving = true;
    try {
      await ajax("/admin/plugins/crypto-ticker/coins", {
        type: "PUT",
        data: { coins: this.selectedIds.join("|") },
      });
      this.saved = true;
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.saving = false;
    }
  }
}
