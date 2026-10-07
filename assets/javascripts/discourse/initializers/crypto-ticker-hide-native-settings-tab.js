// Discourse always prepends a native "change settings" tab to a plugin's admin
// config nav. Our plugin provides its own fully-translated Settings tab, so we
// hide the native one. It is always the FIRST tab (the core unshifts it).
export default {
  name: "crypto-ticker-hide-native-settings-tab",

  initialize(container) {
    const router = container.lookup("service:router");

    const hide = () => {
      if (
        !window.location.pathname.startsWith(
          "/admin/plugins/discourse-crypto-ticker"
        )
      ) {
        return;
      }

      const tabs = document.querySelectorAll(
        ".admin-plugin-config-page__top-nav-item"
      );
      if (tabs.length < 2) {
        return;
      }

      const first = tabs[0];
      const href =
        first.getAttribute("href") ||
        first.querySelector("a")?.getAttribute("href") ||
        "";

      // Only hide when it is clearly the native settings tab (or when we cannot
      // read the href): never hide one of ours (they contain "/crypto-ticker/").
      if (!href || (href.includes("/settings") && !href.includes("/crypto-ticker/"))) {
        first.style.display = "none";
      }
    };

    router.on("routeDidChange", () => window.setTimeout(hide, 30));
    window.setTimeout(hide, 400);
  },
};
