import 'package:flutter/material.dart';
import 'detail_pesanan.dart';
import 'services/api_service.dart';

// ================= WARNA =================
const _orange = Color(0xFFFF8605);
const _green = Color(0xFF34C759);
const _titleColor = Color(0xFF1F21AA);
const _bgColor = Color(0xFF9CA7D2);

// ================= STATUS =================
enum OrderStatus { selesai, diproses }

// ================= MODEL ITEM =================
class OrderItem {
  final String imageUrl;
  final String name;
  final int qty;
  final int price;
// ================= KONSTRUKTOR =================
  const OrderItem({
    required this.imageUrl,
    required this.name,
    required this.qty,
    required this.price,
  });

  factory OrderItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return OrderItem(
      imageUrl: json['imageUrl'] ?? '',
      name: json['name'] ?? '',
      qty:
          int.tryParse(
            json['qty'].toString(),
          ) ??
          0,
      price:
          int.tryParse(
            json['price'].toString(),
          ) ??
          0,
    );
  }
}

// ================= MODEL ORDER =================
class Order {
  final int id;
  final String name;
  final String date;
  final String phone;
  final String metode;

  OrderStatus status;
// Menyimpan list item dalam order
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.name,
    required this.date,
    required this.phone,
    required this.status,
    required this.items,
    required this.metode,
  });
// Hitung total harga berdasarkan item dan qty
  int get total =>
      items.fold(
        0,
        (sum, i) =>
            sum + (i.price * i.qty),
      );

  factory Order.fromJson(
    Map<String, dynamic> json,
  ) {
    print("JSON API = $json");

    return Order(
      id:
          int.tryParse(
            json['id'].toString(),
          ) ??
          0,

      name: json['name'] ?? '',
      date: json['date'] ?? '',
      phone: json['phone'] ?? '',

      status:
          json['status'] == 'selesai'
              ? OrderStatus.selesai
              : OrderStatus.diproses,
      // Parsing list item dari JSON
      items:
          (json['items'] as List? ?? [])
              .map(
                (e) =>
                    OrderItem.fromJson(e),
              )
              .toList(),

      // ================= METODE PEMBAYARAN =================
      metode:
          (json['metode'] ?? '')
              .toString()
              .toLowerCase()
              .trim(),
    );
  }
}

// Menyimpan list order dalam ValueNotifier untuk update UI otomatis
final ordersNotifier =
    ValueNotifier<List<Order>>([]);

List<Order> get orders =>
    ordersNotifier.value;

// ================= UPDATE STATUS =================
void updateOrderStatus(
  Order order,
  OrderStatus newStatus,
) async {
  order.status = newStatus;
// Update UI secara langsung tanpa reload semua data
  ordersNotifier.notifyListeners();

  await ApiService().updateStatus(
    order.id,
    newStatus ==
            OrderStatus.selesai
        ? "selesai"
        : "diproses",
  );
}

// ================= LOAD ORDER =================
Future<void> loadOrders() async {
  try {
    final data =
        await ApiService().fetchPesanan();

    ordersNotifier.value =
        data
            .map((e) => Order.fromJson(e))
            .toList();
  } catch (e) {
    print("ERROR LOAD ORDERS: $e");
  }
}

// ================= HALAMAN ADMIN =================
class DaftarOrderPage
    extends StatefulWidget {
  const DaftarOrderPage({
    super.key,
  });

  @override
  State<DaftarOrderPage>
  createState() =>
      _DaftarOrderPageState();
}

class _DaftarOrderPageState
    extends State<DaftarOrderPage> {
  // Controller untuk search bar
  final _searchCtrl =
      TextEditingController();

  String _query = '';

  @override
  void initState() {
    super.initState();
    loadOrders();
  }
  // Pastikan untuk membersihkan controller saat widget dihapus dari tree
  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
// ================= BUILD UI =================
  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: _bgColor,

      body: SafeArea(
        child:
            ValueListenableBuilder<
              List<Order>
            >(
              valueListenable:
                  ordersNotifier,

              builder: (
                context,
                orderList,
                _,
              ) {
               final list = orderList
    // Filter berdasarkan query pencarian
    .where(
      (o) => o.name
          .toLowerCase()
          .contains(_query),
    )
    .toList()

  // urutkan berdasarkan tanggal terbaru
  ..sort((a, b) {
    final dateA = DateTime.tryParse(a.date) ?? DateTime(2000);
    final dateB = DateTime.tryParse(b.date) ?? DateTime(2000);

    // jika tanggal sama, urutkan berdasarkan ID terbesar
    if (dateA == dateB) {
      return b.id.compareTo(a.id);
    }

    return dateB.compareTo(dateA);
  });

final latestOrders = list.take(10).toList();
                return Column(
                  children: [
                    _buildHeader(),
                    _buildSearchBar(),

                    const SizedBox(
                      height: 16,
                    ),

                    Expanded(
                      child:
                          _buildOrderList(latestOrders)
                    ),
                  ],
                );
              },
            ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(16),

      child: Align(
        alignment:
            Alignment.centerLeft,

        child: Text(
          'Dashboard Admin',

          style: TextStyle(
            color: _titleColor,
            fontSize: 24,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ================= SEARCH =================
  Widget _buildSearchBar() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
            horizontal: 16,
          ),
// Membuat search bar dengan TextField/kotak dan dekorasi yang menarik
      child: TextField(
        controller: _searchCtrl,

        onChanged:
            (v) => setState(
              () =>
                  _query =
                      v.toLowerCase(),
            ),

        decoration: InputDecoration(
          hintText: 'Cari nama...',
          // Membuat ikon pencarian di dalam TextField
          prefixIcon: const Icon(
            Icons.search,
          ),

          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
                  25,
                ),
            // Menghilangkan border default pada TextField agar lebih rapi
            borderSide:
                BorderSide.none,
          ),
          // Menghilangkan padding default pada TextField agar lebih rapi
          contentPadding:
              EdgeInsets.zero,
        ),
      ),
    );
  }

  // ================= LIST ORDER =================
  Widget _buildOrderList(
    List<Order> list,
  ) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          'Data tidak ditemukan',
        ),
      );
    }
    // Membuat daftar order yang bisa di scroll
    return ListView.builder(
      padding:
          const EdgeInsets.symmetric(
            horizontal: 16,
          ),

      itemCount: list.length,
      // Membuat setiap item order menggunakan widget OrderCard
      itemBuilder:
          (context, index) => OrderCard(
            order: list[index],

            onStatusChanged:
                () => setState(() {}),
          ),
    );
  }
}

// ================= CARD ORDER =================
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onStatusChanged;

  const OrderCard({
    super.key,
    required this.order,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelesai =
        order.status == OrderStatus.selesai;

    return Card(
      color: Colors.white,
      // Memberikan bayangan pada card agar terlihat lebih menonjol
      elevation: 3,
      // Memberikan jarak antar card agar tidak terlalu rapat
      margin: const EdgeInsets.only(bottom: 12),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      child: ListTile(
        isThreeLine: true,

        // ================= NOMOR =================
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1F21AA),

          child: Text(
            '${order.id}',

            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // ================= NAMA =================
        title: Text(
          order.name,

          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),

          maxLines: 1,
          // Menambahkan elipsis (...) jika nama terlalu panjang
          overflow: TextOverflow.ellipsis,
        ),

        // ================= TANGGAL & HP =================
        subtitle: Text(
          '${order.date}\n${order.phone}',

          style: const TextStyle(
            color: Colors.black54,
          ),
        ),

        // ================= STATUS & DETAIL =================
        // Menampilkan status pesanan dengan warna yang berbeda dan tombol untuk melihat detail
        trailing: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),

              decoration: BoxDecoration(
                color:
                    isSelesai
                        ? _green
                        : _orange,

                borderRadius:
                    BorderRadius.circular(8),
              ),

              child: Text(
                isSelesai
                    ? 'Selesai'
                    : 'Diproses',

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),

            const SizedBox(height: 4),
            // ================= TOMBOL DETAIL =================
            GestureDetector(
              onTap: () => Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) => DetailPesananPage(
                    order: order,
                    onStatusChanged:
                        onStatusChanged,
                  ),
                ),
              ),

              child: const Text(
                'Detail >',

                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}