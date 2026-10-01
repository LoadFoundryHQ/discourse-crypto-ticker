import { withPluginApi } from "discourse/lib/plugin-api";
import CryptoTicker from "discourse/plugins/discourse-crypto-ticker/discourse/components/crypto-ticker";

export default {
  name: "crypto-ticker-position",

  initialize(container) {
    const siteSettings = container.lookup("service:site-settings");
    const position = siteSettings.crypto_ticker_position || "below-site-header";

    withPluginApi((api) => {
      api.renderInOutlet(position, CryptoTicker);
    });
  },
};
