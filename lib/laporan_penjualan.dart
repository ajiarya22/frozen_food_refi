import 'package:flutter/material.dart';
import 'beranda_admin.dart';

const _navy       = Color(0xFF1F5FBF);
const _green      = Color(0xFF34C759);
const _titleColor = Color(0xFF1F21AA);
const _bgColor    = Color(0xFF9CA7D2);

class LaporanItem {
  final int no;
  final String name;
  final String date;
  final String phone;
  final int total;
  final String metode;

  const LaporanItem({
    required this.no,
    required this.name,
    required this.date,
    required this.phone,
    required this.total,
    required this.metode,
  });
}

class LaporanPenjualanPage extends StatefulWidget {
  const LaporanPenjualanPage({super.key});

  @override
  State<LaporanPenjualanPage> createState() => _LaporanPenjualanPageState();
}

class _LaporanPenjualanPageState extends State<LaporanPenjualanPage> {

  int _selectedMonth = DateTime.now().month;
  String _metode = 'global';

  // ← Sesuaikan dengan nilai DB: 'Tunai' dan 'Non-Tunai'
  String _normalizeMetode(String s) {
    final trimmed = s.trim();
    if (trimmed == 'Tunai') return 'Tunai';
    if (trimmed == 'Non-Tunai') return 'Non-Tunai';
    // fallback jika ada variasi lain
    final lower = trimmed.toLowerCase();
    if (lower.contains('non') || lower.contains('transfer') || lower.contains('qris')) {
      return 'Non-Tunai';
    }
    return 'Tunai';
  }

  List<LaporanItem> _buildLaporan(List<Order> orderList) {
    final filtered = orderList.where((o) {
      // Hanya yang sudah selesai
      if (o.status != OrderStatus.selesai) return false;

      // Filter bulan
      final orderDate = DateTime.tryParse(o.date);
      if (orderDate == null) return false;
      if (orderDate.month != _selectedMonth) return false;

      // Filter metode — cocokkan dengan nilai DB 'Tunai' / 'Non-Tunai'
      final metodeNormal = _normalizeMetode(o.metode);
      if (_metode == 'Tunai' && metodeNormal != 'Tunai') return false;
      if (_metode == 'Non-Tunai' && metodeNormal != 'Non-Tunai') return false;
      // 'global' → tampilkan semua

      return true;
    }).toList();

    return filtered.asMap().entries.map((e) {
      final o = e.value;
      return LaporanItem(
        no: e.key + 1,
        name: o.name,
        date: o.date,
        phone: o.phone,
        total: o.total,
        metode: _normalizeMetode(o.metode),
      );
    }).toList();
  }

  String _formatRupiah(int value) {
    final str = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return 'Rp. ${buf.toString()}';
  }

  void _showFilterPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final months = [
              'Jan','Feb','Mar','Apr','Mei','Jun',
              'Jul','Agu','Sep','Okt','Nov','Des'
            ];

            // ← value disesuaikan dengan nilai di DB
            final metodeList = [
              {'label': 'Global',          'value': 'global'},
              {'label': 'Tunai',           'value': 'Tunai'},
              {'label': 'Transfer / QRIS', 'value': 'Non-Tunai'},
            ];

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Filter',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Filter Bulan
                  Wrap(
                    spacing: 6,
                    children: List.generate(12, (i) {
                      final m = i + 1;
                      return ChoiceChip(
                        label: Text(months[i]),
                        selected: _selectedMonth == m,
                        onSelected: (_) =>
                            setModalState(() => _selectedMonth = m),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // Filter Metode
                  Wrap(
                    spacing: 6,
                    children: metodeList.map((e) {
                      return ChoiceChip(
                        label: Text(e['label']!),
                        selected: _metode == e['value'],
                        onSelected: (_) =>
                            setModalState(() => _metode = e['value']!),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: const Text('Terapkan'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getMonthShort(int month) {
    const m = [
      'Jan','Feb','Mar','Apr','Mei','Jun',
      'Jul','Agu','Sep','Okt','Nov','Des'
    ];
    return m[month - 1];
  }

  String _getMetodeName(String metode) {
    switch (metode) {
      case 'Tunai':     return 'Tunai';
      case 'Non-Tunai': return 'Transfer / QRIS';
      default:          return 'Global';
    }
  }

  Color _getMetodeColor(String metode) {
    return metode == 'Non-Tunai' ? Colors.blue : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: ValueListenableBuilder<List<Order>>(
          valueListenable: ordersNotifier,
          builder: (context, orderList, _) {
            final allLaporan = _buildLaporan(orderList);
            final grandTotal = allLaporan.fold(0, (sum, l) => sum + l.total);

            return Column(
              children: [

                // Title
                const Padding(
                  padding: EdgeInsets.fromLTRB(13, 16, 13, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Laporan Penjualan',
                      style: TextStyle(
                        color: _titleColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // Filter Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: GestureDetector(
                    onTap: () => _showFilterPicker(context),
                    child: Container(
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_getMonthShort(_selectedMonth)} | ${_getMetodeName(_metode)}',
                            ),
                          ),
                          const Icon(Icons.tune),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Header Tabel
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Row(
                      children: [
                        SizedBox(width: 34, child: Text('No.')),
                        Expanded(child: Text('Nama / Tgl')),
                        Text('Metode'),
                        SizedBox(width: 8),
                        Text('Total'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // List Laporan
                Expanded(
                  child: allLaporan.isEmpty
                      ? const Center(
                          child: Text('Tidak ada data',
                              style: TextStyle(color: Colors.white70)))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          itemCount: allLaporan.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 6),
                          itemBuilder: (_, i) => _LaporanCard(
                            item: allLaporan[i],
                            formatRupiah: _formatRupiah,
                            metodeColor: _getMetodeColor(allLaporan[i].metode),
                          ),
                        ),
                ),

                // Grand Total
                Padding(
                  padding: const EdgeInsets.fromLTRB(13, 8, 13, 12),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Penjualan:'),
                        Text(
                          _formatRupiah(grandTotal),
                          style: const TextStyle(
                            color: _titleColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LaporanCard extends StatelessWidget {
  final LaporanItem item;
  final String Function(int) formatRupiah;
  final Color metodeColor;

  const _LaporanCard({
    required this.item,
    required this.formatRupiah,
    required this.metodeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // Nomor urut
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Color(0xFF5F6AA4),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text('${item.no}',
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 10),

          // Nama, tanggal, hp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(item.date,
                    style: const TextStyle(color: _navy, fontSize: 12)),
                if (item.phone.isNotEmpty)
                  Text(item.phone, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),

          // Badge metode + status + total
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Badge metode pembayaran
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: metodeColor,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  item.metode, // tampil 'Tunai' atau 'Non-Tunai' langsung dari DB
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
              const SizedBox(height: 3),
              // Badge selesai
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text('Selesai',
                    style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
              const SizedBox(height: 4),
              Text(formatRupiah(item.total),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}