import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'beranda_admin.dart';

class DetailPesananPage extends StatefulWidget {
  final Order order;
  final VoidCallback onStatusChanged;

  const DetailPesananPage({
    super.key,
    required this.order,
    required this.onStatusChanged,
  });

  @override
  State<DetailPesananPage> createState() => _DetailPesananPageState();
}

class _DetailPesananPageState extends State<DetailPesananPage> {
  static const String serverHost = "192.168.18.229";

  // ================= WHATSAPP =================
  Future<void> sendWhatsAppAuto() async {
    const String token = "SGiUXtd9M3JPsDLRN9Za";

    String phone =
        widget.order.phone.replaceAll(RegExp(r'[^0-9]'), '');

    // otomatis ubah 08 -> 628
    if (phone.startsWith("08")) {
      phone = "62${phone.substring(1)}";
    }

    // ================= DETAIL PRODUK =================
    String productList = "";

    for (var item in widget.order.items) {
      productList += "- ${item.name} (${item.qty}x)\n";
    }

    // ================= TOTAL ITEM =================
    int totalItem = 0;

    for (var item in widget.order.items) {
      totalItem += item.qty;
    }

    // ================= ID PESANAN =================
    String orderId = widget.order.id.toString();

    // ================= TEMPLATE PESAN =================
    final String message = '''
Halo ${widget.order.name} 👋

Pesanan Anda sudah selesai dan siap diambil ✅

📌 Detail Pesanan:
🆔 ID Pesanan : $orderId
🛒 Jumlah Item : $totalItem
💰 Total Bayar : Rp ${widget.order.total}

📦 Produk:
$productList

Terima kasih sudah memesan 🙏
''';

    try {
      final response = await http.post(
        Uri.parse("https://api.fonnte.com/send"),
        headers: {
          "Authorization": token,
        },
        body: {
          "target": phone,
          "message": message,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("WA berhasil dikirim"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Gagal kirim WA: ${response.body}",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("ERROR: $e"),
        ),
      );
    }
  }

  // ================= URL GAMBAR =================
  String getImageUrl(String path) {
    if (path.isEmpty) return "";

    path = path.trim();
    path = path.replaceAll("\\", "/");
    path = path.replaceAll("localhost", serverHost);
    path = path.replaceAll("192.168.1.11", serverHost);

    if (path.startsWith("http://") ||
        path.startsWith("https://")) {
      return Uri.encodeFull(path);
    }

    while (path.startsWith("/")) {
      path = path.substring(1);
    }

    if (!path.startsWith("img/")) {
      path = "img/$path";
    }

    return Uri.encodeFull(
      "http://$serverHost/$path",
    );
  }

  // ================= DIALOG SELESAI =================
  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          alignment: Alignment.topCenter,
          backgroundColor: const Color(0xFF34C759),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),

          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
              ),

              SizedBox(width: 10),

              Text(
                "Selesaikan Pesanan?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          content: const Text(
            "Anda akan mengubah status pesanan ini menjadi SELESAI.",

            style: TextStyle(
              color: Colors.white,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text(
                "BATAL",

                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF34C759),
              ),

              onPressed: () async {
                updateOrderStatus(
                  widget.order,
                  OrderStatus.selesai,
                );

                widget.onStatusChanged();

                setState(() {});

                Navigator.pop(dialogContext);

                await sendWhatsAppAuto();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      "Pesanan selesai & WA terkirim!",
                    ),

                    backgroundColor: Colors.green[800],

                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },

              child: const Text("YA, UBAH"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;

    return Scaffold(
      backgroundColor: const Color(0xFF9CA7D2),

      // ================= APPBAR =================
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // ================= CARD =================
            Card(
              elevation: 3,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  children: [
                    // ================= INFO =================
                    _infoRow('Nama', o.name),
                    _infoRow('Tanggal', o.date),
                    _infoRow('Telepon', o.phone),

                    _infoRow(
                      'Pembayaran',
                      o.metode
                              .toLowerCase()
                              .trim()
                              .contains("non")
                          ? 'Transfer'
                          : 'Tunai',
                    ),

                    const Divider(
                      height: 30,
                      thickness: 1,
                    ),

                    // ================= LIST PRODUK =================
                    ...o.items.map((item) {
                      final imageUrl =
                          getImageUrl(item.imageUrl);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),

                        child: Row(
                          children: [
                            // ================= GAMBAR =================
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(8),

                              child: imageUrl.isEmpty
                                  ? _placeholder()
                                  : Image.network(
                                      imageUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      gaplessPlayback: true,
                                      cacheWidth: 300,

                                      loadingBuilder: (
                                        context,
                                        child,
                                        progress,
                                      ) {
                                        if (progress == null) {
                                          return child;
                                        }

                                        return Container(
                                          width: 60,
                                          height: 60,
                                          color: Colors.grey[200],

                                          child: const Center(
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },

                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return _placeholder();
                                      },
                                    ),
                            ),

                            const SizedBox(width: 12),

                            // ================= DETAIL =================
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    item.name,

                                    style: const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    '${item.qty} x Rp ${item.price}',

                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ================= TOTAL =================
                            Text(
                              'Rp ${item.qty * item.price}',

                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const Divider(
                      height: 30,
                      thickness: 1,
                    ),

                    // ================= TOTAL BAYAR =================
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          'Total Pembayaran',

                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          'Rp ${o.total}',

                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ================= BUTTON =================
            if (o.status != OrderStatus.selesai)
              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: () {
                    _showStatusDialog();
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF34C759),

                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 15,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),

                  child: const Text(
                    'Selesaikan Pesanan',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ================= PLACEHOLDER =================
  Widget _placeholder() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey[300],

      child: const Icon(
        Icons.fastfood,
        size: 30,
      ),
    );
  }

  // ================= INFO ROW =================
  Widget _infoRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 90,

            child: Text(
              '$label:',

              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,

              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
