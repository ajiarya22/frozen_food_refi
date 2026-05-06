import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const Color kPrimary    = Color(0xFF4919B9);
const Color kBackground = Color(0xFF9CA7D2);
const Color kBlue       = Color(0xFF1F21AA);

class KontakPage extends StatelessWidget {
  const KontakPage({super.key});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,

      // ─── BODY ───────────────────────────────────────────
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── JUDUL ──
              const Padding(
                padding: EdgeInsets.only(top: 18, bottom: 14),
                child: Center(
                  child: Text(
                    'Kontak',
                    style: TextStyle(
                      color: kBlue,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

          
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Usaha',
                      style: TextStyle(
                        color: kBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(
                      iconWidget: _CircleIcon(
                        bgColor: const Color(0xFFE8EAEE),
                        child: const Icon(Icons.location_on, color: Color(0xFF7C85B0), size: 22),
                      ),
                      label: 'Alamat',
                      value: 'Jl. Dahlia No.II , Ds. Warujayeng',
                    ),
                    _divider(),
                    _InfoRow(
                      iconWidget: _CircleIcon(
                        bgColor: const Color(0xFFE8EAEE),
                        child: const Icon(Icons.phone, color: Color(0xFF4CAF50), size: 22),
                      ),
                      label: 'No. Telepon',
                      value: '0857-5535-4846',
                    ),
                    _divider(),
                    _InfoRow(
                      iconWidget: _CircleIcon(
                        bgColor: const Color(0xFFE8EAEE),
                        child: const Icon(Icons.access_time, color: Color(0xFFFF9800), size: 22),
                      ),
                      label: 'Jam Operasional',
                      value: '08:00-16:00 WIB',
                    ),
                    _divider(),
                    _InfoRow(
                      iconWidget: _CircleIcon(
                        bgColor: const Color(0xFFE8EAEE),
                        child: const Icon(Icons.storefront, color: Color(0xFF9C27B0), size: 22),
                      ),
                      label: 'Jenis Usaha',
                      value: 'Toko Refi Frozen Food',
                    ),
                    const SizedBox(height: 16),

                    // ── SOSMED ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _SosmedCircle(
                          icon: FontAwesomeIcons.whatsapp,
                          label: 'WhatsApp',
                          onTap: () => _launch('https://wa.me/6285755354846'),
                        ),
                        const SizedBox(width: 150),
                        _SosmedCircle(
                          icon: FontAwesomeIcons.tiktok,
                          label: 'TikTok',
                          onTap: () => _launch('https://www.tiktok.com/@refifrozenfood0?_r=1&_t=ZS-94d3UiEUoFk'),
                        ),
                        const SizedBox(width: 140),
                        _SosmedCircle(
                          icon: FontAwesomeIcons.instagram,
                          label: 'Instagram',
                          onTap: () => _launch('https://www.instagram.com/refi_frozenfood_warujayeng?igsh=MThyMWViNXNpeXhhZA=='),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── LOKASI KAMI ──
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lokasi Kami',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _launch('https://maps.app.goo.gl/xV5jJo9WZhq1RPvm8?g_st=aw'),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: double.infinity,
                          height: 160,
                          child: FlutterMap(
                            options: const MapOptions(
                              initialCenter: LatLng(-7.5631, 111.9187),
                              initialZoom: 15,
                              interactionOptions: InteractionOptions(
                                flags: InteractiveFlag.none, // nonaktifkan gesture supaya tap buka Maps
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.app', // ganti dengan package name kamu
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: const LatLng(-7.5631, 111.9187),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 36,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _launch('https://maps.app.goo.gl/xV5jJo9WZhq1RPvm8?g_st=aw'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.open_in_new, size: 14, color: kBlue),
                          SizedBox(width: 4),
                          Text(
                            'Buka di Google Maps',
                            style: TextStyle(
                              fontSize: 12,
                              color: kBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),

      // ─── BOTTOM NAVIGATION BAR ──────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFF4919B9),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/beranda');
          } else if (index == 1) {
            // Sudah di Kontak
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/katalog');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone),
            label: 'Kontak',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Katalog',
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, thickness: 1, color: Colors.grey.shade200);

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(18), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────
// WIDGET PEMBANTU
// ─────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _InfoRow({required this.iconWidget, required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.chevron_right, color: Colors.black26, size: 18),
          ],
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final Color bgColor;
  final Widget child;
  const _CircleIcon({required this.bgColor, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46, height: 46,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Center(child: child),
    );
  }
}

class _SosmedCircle extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SosmedCircle({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48, height: 48,
        decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
} 