import Route from "@ember/routing/route";
import { ajax } from "discourse/lib/ajax";

export default class CryptoTickerSectionRoute extends Route {
  model() {
    return ajax("/admin/plugins/crypto-ticker/coins.json");
  }

  setupController(controller, model) {
    controller.setProperties({
      allCoins: model.coins || [],
      topCoins: model.top || [],
      selectedIds: model.selected || [],
      indexes: model.indexes || [],
      selectedStocks: model.selected_stocks || [],
    });
  }
}
