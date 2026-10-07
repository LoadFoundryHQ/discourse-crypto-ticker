import Route from "@ember/routing/route";
import { ajax } from "discourse/lib/ajax";

export default class CryptoTickerSettingsRoute extends Route {
  model() {
    return ajax("/admin/plugins/crypto-ticker/config.json");
  }

  setupController(controller, model) {
    controller.setProperties({
      enabled: model.enabled,
      position: model.position,
      style: model.style,
      language: model.language,
    });
  }
}
