import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'kelola_produk.dart';

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
        _allProduk = data
            .map((item) => Produk(
                  id: item['id'].toString(),
                  nama: item['nama'].toString(),
                  kategori: item['kategori'] ?? 'Sosis',
                  deskripsi: item['deskripsi'] ?? '',
                  stock: int.parse(item['stock'].toString()),
                  harga: double.parse(item['harga'].toString()),
                  imageUrl: item['image_url'] ?? '',
                ))
            .toList();
      });
    } catch (e) {
      debugPrint("Gagal muat Beranda: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Produk> get filteredProducts {
    final keyword = search.toLowerCase();

    return _allProduk.where((p) {
      final matchesSearch = p.nama.toLowerCase().contains(keyword) ||
          p.deskripsi.toLowerCase().contains(keyword);

      if (keyword.isNotEmpty) return matchesSearch;

      return p.kategori.toLowerCase() ==
          selectedCategory.toLowerCase();
    }).toList();
  }

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
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF5A22D6)
                : const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(50),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF5A22D6).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget productCard(Produk produk) {
    return Expanded(
      child: Container(
        height: 240,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF4C1FD3),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                "$storageUrl${produk.imageUrl}",
                height: 95,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 95,
                    color: const Color(0xFF6B3DD1),
                    child: const Center(
                      child: Icon(
                        Icons.fastfood,
                        color: Colors.white54,
                        size: 35,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            Text(
              produk.nama,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 5),

            Expanded(
              child: Text(
                produk.deskripsi,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Rp. ${produk.harga.toInt()}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = filteredProducts;

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
      backgroundColor: const Color(0xFFB0B7E3),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                /// BACKGROUND ATAS
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                  decoration: const BoxDecoration(
                    color: Color(0xFFAAB2DE),
                  ),
                  child: Column(
                    children: [
                      /// HEADER
                      Row(
                        children: [
                          Container(
                            width: 85,
                            height: 85,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  const AssetImage("assets/logo_refi.png"),
                              onBackgroundImageError: (_, __) {},
                            ),
                          ),

                          const SizedBox(width: 14),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Selamat Datang Di",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2727B8),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "REFI FROZEN FOOD",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      /// SEARCH
                      Container(
                        height: 45,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8F8),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              search = value.trim();
                            });
                          },
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search...",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                            icon: Icon(
                              Icons.search,
                              color: Colors.black87,
                              size: 22,
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// BACKGROUND PUTIH
                Transform.translate(
                  offset: const Offset(0, -15),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 22, 16, 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// KATEGORI
                        Row(
                          children: [
                            categoryButton("Sosis"),
                            categoryButton("Nugget"),
                            categoryButton("Bakso"),
                          ],
                        ),

                        const SizedBox(height: 22),

                        Text(
                          selectedCategory,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4C1FD3),
                          ),
                        ),

                        const SizedBox(height: 10),

                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (data.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                "Produk tidak ditemukan",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        else
                          ...productRows,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}