import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';


class Produk {
  final String id;
  final String nama;
  final String kategori; // Tambahan Kategori
  final String deskripsi;
  final int stock;
  final double harga;
  final String imageUrl;

  Produk({
    required this.id,
    required this.nama,
    required this.kategori, // Tambahan Kategori
    required this.deskripsi,
    required this.stock,
    required this.harga,
    required this.imageUrl,
  });
}

class KelolaProdukScreen extends StatefulWidget {
  const KelolaProdukScreen({super.key});

  @override 
  State<KelolaProdukScreen> createState() => _KelolaProdukScreenState();
}

class _KelolaProdukScreenState extends State<KelolaProdukScreen> {
  // Sesuaikan IP Server
  static const String serverHost = kIsWeb ? "localhost" : "192.168.18.195";
  final String apiUrl = "http://$serverHost/produk_api.php";
  final String storageUrl = "http://$serverHost/img/";

  List<Produk> _allProduk = [];
  List<Produk> _filteredProduk = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _allProduk = data.map((item) => Produk(
                id: item['id']?.toString() ?? '',
                nama: item['nama']?.toString() ?? '',
                kategori: item['kategori']?.toString() ?? 'Sosis', // Ambil Kategori
                deskripsi: item['deskripsi']?.toString() ?? '',
                stock: int.tryParse(item['stock'].toString()) ?? 0,
                harga: double.tryParse(item['harga'].toString()) ?? 0,
                imageUrl: item['image_url']?.toString() ?? '',
              )).toList();
          _filteredProduk = _allProduk;
        });
      }
    } catch (e) {
      debugPrint("Gagal memuat data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _runFilter(String enteredKeyword) {
    List<Produk> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allProduk;
    } else {
      results = _allProduk
          .where((p) => p.nama.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() => _filteredProduk = results);
  }

  Future<void> _deleteData(String id) async {
    try {
      final response = await http.delete(Uri.parse("$apiUrl?id=$id"));
      if (response.statusCode == 200) {
        _fetchData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Produk dihapus"), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      debugPrint("Gagal menghapus: $e");
    }
  }

  void _confirmDelete(String id, String nama) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Produk"),
        content: Text("Yakin ingin menghapus '$nama'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () { _deleteData(id); Navigator.pop(ctx); },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveData(Map<String, dynamic> data, bool isEdit) async {
    try {
      final response = isEdit
          ? await http.put(Uri.parse(apiUrl), headers: {'Content-Type': 'application/json'}, body: json.encode(data))
          : await http.post(Uri.parse(apiUrl), headers: {'Content-Type': 'application/json'}, body: json.encode(data));

      if (response.statusCode == 200) {
        _fetchData();
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Gagal menyimpan: $e");
    }
  }

  void _showForm({Produk? produk}) {
    final isEdit = produk != null;
    final nameCtrl = TextEditingController(text: produk?.nama ?? '');
    final deskCtrl = TextEditingController(text: produk?.deskripsi ?? '');
    final priceCtrl = TextEditingController(text: produk?.harga.toStringAsFixed(0) ?? '');
    
    // Inisialisasi Kategori
    String tempKategori = produk?.kategori ?? 'Sosis';
    List<String> listKategori = ['Sosis', 'Nugget', 'Bakso'];
    
    int tempStock = produk?.stock ?? 0;
    String base64Image = "";
    Uint8List? previewBytes;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> _pickImage() async {
            final picker = ImagePicker();
            final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
            if (image != null) {
              final bytes = await image.readAsBytes();
              setDialogState(() {
                previewBytes = bytes;
                base64Image = base64Encode(bytes);
              });
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 120, width: double.infinity,
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                      child: previewBytes != null
                          ? Image.memory(previewBytes!, fit: BoxFit.cover)
                          : (isEdit && produk.imageUrl.isNotEmpty)
                              ? Image.network("$storageUrl${produk.imageUrl}", fit: BoxFit.cover)
                              : const Icon(Icons.add_a_photo, size: 40),
                    ),
                  ),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Produk')),
                  
                  // Dropdown Kategori
                  DropdownButtonFormField(
                    value: tempKategori,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: listKategori.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                    onChanged: (val) => setDialogState(() => tempKategori = val.toString()),
                  ),
                  
                  TextField(controller: deskCtrl, decoration: const InputDecoration(labelText: 'Deskripsi')),
                  TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Stok:"),
                      IconButton(onPressed: () => setDialogState(() => tempStock > 0 ? tempStock-- : 0), icon: const Icon(Icons.remove_circle, color: Colors.red)),
                      Text(tempStock.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(onPressed: () => setDialogState(() => tempStock++), icon: const Icon(Icons.add_circle, color: Colors.green)),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
              ElevatedButton(onPressed: () {
                final data = {
                  if (isEdit) 'id': produk.id,
                  'nama': nameCtrl.text,
                  'kategori': tempKategori, // Kirim Kategori
                  'deskripsi': deskCtrl.text,
                  'stock': tempStock,
                  'harga': double.tryParse(priceCtrl.text) ?? 0,
                  'image_base64': base64Image,
                };
                _saveData(data, isEdit);
              }, child: const Text("Simpan")),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9CA7D2),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Kelola Produk", 
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold
            ),
          ),
        backgroundColor: const Color(0xFF1F21AA),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _runFilter,
                      decoration: const InputDecoration(
                        hintText: "Cari produk...",
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _showForm(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0xFF1F21AA), shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: Colors.white, size: 30),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: _filteredProduk.length,
                    itemBuilder: (ctx, i) {
                      final p = _filteredProduk[i];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  "$storageUrl${p.imageUrl}",
                                  width: 80, height: 80, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: Colors.grey[300], child: const Icon(Icons.fastfood)),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    // Label Kategori agar mudah dilihat admin
                                    Text(p.kategori, style: const TextStyle(fontSize: 12, color: Color(0xFF1F21AA), fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text("Stok: ${p.stock} | Rp ${p.harga.toInt()}", style: TextStyle(color: Colors.grey[700])),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDelete(p.id, p.nama)),
                                  IconButton(icon: const Icon(Icons.edit, color: Colors.grey), onPressed: () => _showForm(produk: p)),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}