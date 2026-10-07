import { withPluginApi } from "discourse/lib/plugin-api";

const PLUGIN_ID = "discourse-crypto-ticker";

export default {
  name: "crypto-ticker-admin-plugin-configuration-nav",

  initialize(container) {
    const currentUser = container.lookup("service:current-user");
    if (!currentUser?.admin) {
      return;
    }

    withPluginApi((api) => {
      api.setAdminPluginIcon(PLUGIN_ID, "coins");
      api.addAdminPluginConfigurationNav(PLUGIN_ID, [
        {
          label: "crypto_ticker.admin.tab_crypto",
          route: "adminPlugins.show.crypto-ticker-coins",
          icon: "coins",
        },
        {
          label: "crypto_ticker.admin.tab_stocks",
          route: "adminPlugins.show.crypto-ticker-stocks",
          icon: "chart-line",
        },
        {
          label: "crypto_ticker.admin.tab_indexes",
          route: "adminPlugins.show.crypto-ticker-indexes",
          icon: "chart-column",
        },
      ]);
    });
  },
};
