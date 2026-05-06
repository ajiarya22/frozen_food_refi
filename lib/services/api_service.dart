import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String serverHost = "192.168.0.139";

  static const String baseUrlProduk =
      "http://$serverHost/produk_api.php";

  static const String baseUrlTransaksi =
      "http://$serverHost/simpan_transaksi.php";

  static const String baseUrlAdmin =
      "http://$serverHost/admin_api.php";

  static const String baseUrlPesanan =
      "http://$serverHost/get_pesanan.php";

  static const String baseUrlUpdateStatus =
      "http://$serverHost/update_status.php";

  // ==============================
  // 🔐 LOGIN ADMIN
  // ==============================
  Future<Map<String, dynamic>> loginAdmin(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrlAdmin),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'action': 'login',
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // ==============================
  // 👤 GET ADMIN BY ID
  // ==============================
  Future<Map<String, dynamic>> getAdminById(int id) async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrlAdmin?id=$id"));

      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // ==============================
  // ✏️ UPDATE ADMIN
  // ==============================
  Future<Map<String, dynamic>> updateAdmin(
      Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse(baseUrlAdmin),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // ==============================
  // 📦 PRODUK
  // ==============================
  Future<List<dynamic>> fetchProduk() async {
    try {
      final response = await http.get(Uri.parse(baseUrlProduk));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> saveProduk(
      Map<String, dynamic> data, bool isEdit) async {
    try {
      final response = isEdit
          ? await http.put(
              Uri.parse(baseUrlProduk),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(data),
            )
          : await http.post(
              Uri.parse(baseUrlProduk),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(data),
            );

      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  Future<bool> deleteProduk(String id) async {
    try {
      final response =
          await http.delete(Uri.parse("$baseUrlProduk?id=$id"));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==============================
  // 🛒 KIRIM PESANAN (CHECKOUT)
  // ==============================
  Future<Map<String, dynamic>> kirimPesanan(
      Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrlTransaksi),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // ==============================
  // 📄 GET PESANAN (SUDAH NESTED)
  // ==============================
  Future<List<dynamic>> fetchPesanan() async {
    try {
      final response =
          await http.get(Uri.parse(baseUrlPesanan));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          return data['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ==============================
  // 🔄 UPDATE STATUS PESANAN
  // ==============================
  Future<Map<String, dynamic>> updateStatus(
      int id, String status) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrlUpdateStatus),
        body: {
          "id": id.toString(),
          "status": status,
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }
}