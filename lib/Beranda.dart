import 'package:flutter/material.dart';
import 'service/api_service.dart';
import 'Kelola_produk.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  String search = "";
  String selectedCategory = "Sosis";

  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProduk();
  }

  Future<void> fetchProduk() async {
    setState(() => isLoading = true);

    var data = await ApiService.getProduk();

    setState(() {
      products = data;
      isLoading = false;
    });
  }

  List<dynamic> get filteredProducts {
    final keyword = search.toLowerCase();

    return products.where((p) {
      final nama = (p['nama'] ?? '').toString().toLowerCase();
      final deskripsi = (p['deskripsi'] ?? '').toString().toLowerCase();
      final kategori = (p['kategori'] ?? '').toString().toLowerCase();

      if (keyword.isNotEmpty) {
        return nama.contains(keyword) || deskripsi.contains(keyword);
      }

      return kategori == selectedCategory.toLowerCase();
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
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF4919B9)
                : const Color(0xFFD9D9D9),
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

  /// 🔥 FIX GAMBAR DI SINI
  Widget productCard(dynamic product) {
    String imageUrl = product["image_url"] ?? "";

    return Expanded(
      child: Container(
        height: 210,
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
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 80,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print("ERROR LOAD IMAGE: $imageUrl");
                        return Container(
                          height: 80,
                          color: const Color(0xFF6B3DD1),
                          child: const Center(
                            child: Icon(Icons.image_not_supported,
                                color: Colors.white54, size: 32),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 80,
                      color: const Color(0xFF6B3DD1),
                      child: const Center(
                        child: Icon(Icons.image,
                            color: Colors.white54, size: 32),
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              product["nama"] ?? "",
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
                product["deskripsi"] ?? "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ),
            Text(
              "Rp ${product["harga"]}",
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
            onRefresh: fetchProduk, // 🔥 tarik refresh
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            const AssetImage("assets/logo_refi.png"),
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

                      const Spacer(),

                      /// 🔥 KE KELOLA PRODUK + AUTO REFRESH
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const KelolaProdukPage()),
                          );

                          fetchProduk(); // refresh setelah balik
                        },
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// SEARCH
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

                  /// LABEL
                  Text(
                    selectedCategory,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4919B9)),
                  ),

                  const SizedBox(height: 10),

                  /// PRODUK
                  if (isLoading)
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
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey)),
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