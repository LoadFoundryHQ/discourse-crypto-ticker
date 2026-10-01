export default {
  resource: "admin.adminPlugins.show",

  path: "/plugins",

  map() {
    this.route("crypto-ticker-picker");
  },
};
