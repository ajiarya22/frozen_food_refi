import 'package:flutter/material.dart';
import 'services/api_service.dart'; // Sesuaikan path services Anda
import 'kelola_produk.dart'; // Untuk mendapatkan Model Produk

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  final ApiService _apiService = ApiService();
  String search = "";
  String selectedCategory = "Sosis";

  List<Produk> _allProduk = [];
  bool _isLoading = true;

  // Menggunakan storageUrl dari ApiService seperti pada fungsi asli
  final String storageUrl = "http://${ApiService.serverHost}/img/";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.fetchProduk();
      setState(() {
        _allProduk = data.map((item) => Produk(
          id: item['id'].toString(),
          nama: item['nama'].toString(),
          kategori: item['kategori'] ?? 'Sosis',
          deskripsi: item['deskripsi'] ?? '',
          stock: int.parse(item['stock'].toString()),
          harga: double.parse(item['harga'].toString()),
          imageUrl: item['image_url'] ?? '',
        )).toList();
      });
    } catch (e) {
      debugPrint("Gagal muat Beranda: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Filter gabungan Kategori & Search
  List<Produk> get filteredProducts {
    final keyword = search.toLowerCase();
    return _allProduk.where((p) {
      final matchesSearch = p.nama.toLowerCase().contains(keyword) || 
                            p.deskripsi.toLowerCase().contains(keyword);
      
      // Jika sedang mencari (search tidak kosong), tampilkan global
      if (keyword.isNotEmpty) return matchesSearch;

      // Jika tidak mencari, filter berdasarkan kategori
      return p.kategori.toLowerCase() == selectedCategory.toLowerCase();
    }).toList();
  }

  // UI Tombol Kategori dari Versi 1
  Widget categoryButton(String title) {
    bool isSelected = selectedCategory == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = title;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4919B9) : const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(50),
            boxShadow: isSelected
                ? [
                    const BoxShadow(
                        color: Color(0x554919B9),
                        blurRadius: 8,
                        offset: Offset(0, 4))
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // UI Kartu Produk dari Versi 1 (dengan data dari Model Produk)
  Widget productCard(Produk produk) {
    return Expanded(
      child: Container(
        height: 220, // Sedikit disesuaikan agar teks muat
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF4919B9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Color(0x40000000),
                blurRadius: 6,
                offset: Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                "$storageUrl${produk.imageUrl}",
                height: 80,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 80,
                  color: const Color(0xFF6B3DD1),
                  child: const Center(
                    child: Icon(Icons.fastfood, color: Colors.white54, size: 32),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              produk.nama,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                produk.deskripsi,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ),
            Text(
              "Rp ${produk.harga.toInt()}",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = filteredProducts;

    // Logika baris (row) manual agar tampilan sama dengan permintaan
    List<Widget> productRows = [];
    for (int i = 0; i < data.length; i += 2) {
      productRows.add(
        Row(
          children: [
            productCard(data[i]),
            if (i + 1 < data.length)
              productCard(data[i + 1])
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF9FA8DA), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _fetchData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER (UI VERSI 1)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        backgroundImage: const AssetImage("assets/logo_refi.png"),
                        onBackgroundImageError: (_, __) {},
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Selamat Datang Di",
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F21AA)),
                          ),
                          Text(
                            "REFI FROZEN FOOD",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// SEARCH (UI VERSI 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8F8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          search = value.trim();
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: "Search",
                        border: InputBorder.none,
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// KATEGORI
                  Row(
                    children: [
                      categoryButton("Sosis"),
                      categoryButton("Nugget"),
                      categoryButton("Bakso"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// LABEL KATEGORI
                  Text(
                    selectedCategory,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4919B9)),
                  ),

                  const SizedBox(height: 10),

                  /// LIST PRODUK
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (data.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text("Produk tidak ditemukan",
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ),
                    )
                  else
                    ...productRows,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}