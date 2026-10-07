export default {
  resource: "admin.adminPlugins.show",

  path: "/plugins",

  map() {
    this.route("crypto-ticker-settings", { path: "crypto-ticker/settings" });
    this.route("crypto-ticker-coins", { path: "crypto-ticker/coins" });
    this.route("crypto-ticker-stocks", { path: "crypto-ticker/stocks" });
    this.route("crypto-ticker-indexes", { path: "crypto-ticker/indexes" });
  },
};
