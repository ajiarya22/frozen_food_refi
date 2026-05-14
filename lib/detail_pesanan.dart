import 'package:flutter/material.dart';
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
  static const String serverHost = "192.168.18.195";

  // ================= URL GAMBAR =================
  String getImageUrl(String path) {
    if (path.isEmpty) return "";

    path = path.trim();
    path = path.replaceAll("\\", "/");
    path = path.replaceAll("localhost", serverHost);
    path = path.replaceAll("192.168.18.195", serverHost);

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

    return Uri.encodeFull("http://$serverHost/$path");
  }

  // ================= DIALOG STATUS =================
  void _showStatusDialog(OrderStatus newStatus) {
    final bool isSelesai =
        newStatus == OrderStatus.selesai;

    final String title = isSelesai
        ? "Selesaikan Pesanan?"
        : "Proses Pesanan?";

    final Color themeColor = isSelesai
        ? const Color(0xFF34C759)
        : const Color(0xFFFF8605);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          alignment: Alignment.topCenter,
          backgroundColor: themeColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),

          title: Row(
            children: [
              Icon(
                isSelesai
                    ? Icons.check_circle
                    : Icons.sync,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          content: Text(
            "Anda akan mengubah status pesanan ini menjadi "
            "${isSelesai ? 'SELESAI' : 'DIPROSES'}.",
            style: const TextStyle(color: Colors.white),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                "BATAL",
                style: TextStyle(color: Colors.white70),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: themeColor,
              ),
              onPressed: () {
                updateOrderStatus(widget.order, newStatus);

                widget.onStatusChanged();

                setState(() {});

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      isSelesai
                          ? "Pesanan selesai! Cek di laporan."
                          : "Status berhasil diperbarui!",
                    ),
                    backgroundColor: isSelesai
                        ? Colors.green[800]
                        : Colors.orange[800],
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

    print("METODE DB = ${o.metode}");

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

                    const Divider(height: 30, thickness: 1),

                    // ================= LIST PRODUK =================
                    ...o.items.map((item) {
                      final imageUrl =
                          getImageUrl(item.imageUrl);

                      print("IMAGE DB = ${item.imageUrl}");
                      print("FINAL URL = $imageUrl");

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

                                      loadingBuilder:
                                          (
                                        context,
                                        child,
                                        progress,
                                      ) {
                                        if (progress ==
                                            null) {
                                          return child;
                                        }

                                        return Container(
                                          width: 60,
                                          height: 60,
                                          color:
                                              Colors.grey[200],

                                          child:
                                              const Center(
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },

                                      errorBuilder:
                                          (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        print(
                                          "ERROR IMAGE = $error",
                                        );

                                        print(
                                          "FAILED URL = $imageUrl",
                                        );

                                        return _placeholder();
                                      },
                                    ),
                            ),

                            const SizedBox(width: 12),

                            // ================= DETAIL PRODUK =================
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [
                                  Text(
                                    item.name,
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    '${item.qty} x Rp ${item.price}',
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ================= TOTAL ITEM =================
                            Text(
                              'Rp ${item.qty * item.price}',
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const Divider(height: 30, thickness: 1),

                    // ================= TOTAL =================
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        Text(
                          'Rp ${o.total}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
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
            Row(
              children: [
                // ================= DIPROSES =================
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showStatusDialog(
                        OrderStatus.diproses,
                      );
                    },

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFFF8605),

                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 15,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),

                    child: const Text(
                      'Set Diproses',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // ================= SELESAI =================
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showStatusDialog(
                        OrderStatus.selesai,
                      );
                    },

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF34C759),

                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 15,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),

                    child: const Text(
                      'Set Selesai',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
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
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}