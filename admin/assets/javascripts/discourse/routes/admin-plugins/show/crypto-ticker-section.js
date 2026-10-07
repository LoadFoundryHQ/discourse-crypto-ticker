import Route from "@ember/routing/route";
import { ajax } from "discourse/lib/ajax";

export default class CryptoTickerSectionRoute extends Route {
  model() {
    return ajax("/admin/plugins/crypto-ticker/coins.json");
  }

  setupController(controller, model) {
    const top = model.top || [];
    const saved = model.selected || [];
    const selectedIds = saved.length
      ? saved
      : top.slice(0, 10).map((coin) => coin.id);

    controller.setProperties({
      allCoins: model.coins || [],
      topCoins: top,
      selectedIds,
      indexes: model.indexes || [],
      selectedStocks: model.selected_stocks || [],
    });
  }
}
