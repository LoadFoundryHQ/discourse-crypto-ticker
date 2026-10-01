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
          label: "crypto_ticker.admin.picker_title",
          route: "adminPlugins.show.crypto-ticker-picker",
        },
      ]);
    });
  },
};
