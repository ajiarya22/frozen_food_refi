class AdminSession {
  static Map<String, dynamic>? adminData;

  static void save(Map<String, dynamic> data) {
    adminData = data;
  }

  static Map<String, dynamic>? get() {
    return adminData;
  }

  static void clear() {
    adminData = null;
  }
}