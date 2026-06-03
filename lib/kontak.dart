import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; //membua aplikasi luar
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; //menambah icon sosial media
import 'package:flutter_map/flutter_map.dart'; //menamppilkan peta
import 'package:latlong2/latlong.dart'; //kordinat lokasi

// ── WARNA GLOBAL ──
const Color kPrimary    = Color(0xFF4919B9); 
const Color kBackground = Color(0xFFB0B7E3); 
const Color kBlue       = Color(0xFF1F21AA);
const Color kSurface    = Colors.white; //8-11 global color untuk menyimpan warna agar tidak ditulis berulang

// ══════════════════════════════════════════
//  WIDGET: APP HEADER
// ══════════════════════════════════════════
class AppHeader extends StatelessWidget { //Membuat header reusable.
  final String title;
  final String subtitle;

  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle, //kenapa di pisah? agar bisa dipakai di halaman lain
  });

  @override
  Widget build(BuildContext context) {
    return Container( //Container wadah backgraund. line 28-31
      width: double.infinity,
      color: const Color(0xFFAAB2DE),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      child: Row( //fungsi row untuk menyusun horizontal
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar( //menampilakn logo bulat
              backgroundColor: Colors.white,
              backgroundImage: const AssetImage('assets/logo_refi.png'),
              onBackgroundImageError: (_, __) {},
            ),
          ),
          const SizedBox(width: 14),
          Expanded( //memeberi ruang fleksibel agar taks tidak oferlow
            child: Column( //fungsi Colom menyusun vertikal, title & subtitle
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF2727B8),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════
//  HALAMAN KONTAK
// ══════════════════════════════════════════
class KontakPage extends StatelessWidget {//kenapa StatelessWidget? karena tidak menyimpan/menampilakn data
  const KontakPage({super.key});

  Future<void> _launch(String url) async { //membuka link
    final uri = Uri.parse(url); //Buat URL jadi Uri
    if (await canLaunchUrl(uri)) { //Cek bisa dibuka atau tidak
      await launchUrl(uri, mode: LaunchMode.externalApplication); //Jika bisa diapaki untuk sosial media
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( //kerangka/pondasi halaman
      backgroundColor: kBackground,
      body: SafeArea( //Agar UI tidak tertutup
        child: SingleChildScrollView( //Membuat halaman bisa di-scroll.
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── HEADER ──
              const AppHeader(
                title: 'Hubungi Kami',
                subtitle: 'REFI FROZEN FOOD',
              ),

              const SizedBox(height: 2),

              // ── INFORMASI USAHA ──
              _buildSection( //Membuat card section reusable/template card.
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Informasi Usaha'),
                    const SizedBox(height: 12),
                    _InfoRow( //Membuat baris informasi.
                      iconWidget: _CircleIcon( //Membuat icon bulat.
                        bgColor: const Color(0xFFEEEDFE),
                        child: const Icon(Icons.location_on, color: kPrimary, size: 20),
                      ),
                      label: 'Alamat',
                      value: 'Jl. Dahlia No.II, Ds. Warujayeng',
                    ),
                    _divider(),
                    _InfoRow(
                      iconWidget: _CircleIcon(
                        bgColor: const Color(0xFFE8F5E9),
                        child: const Icon(Icons.phone, color: Color(0xFF2E7D32), size: 20),
                      ),
                      label: 'No. Telepon',
                      value: '0857-5535-4846',
                    ),
                    _divider(),
                    _InfoRow(
                      iconWidget: _CircleIcon(
                        bgColor: const Color(0xFFFFF3E0),
                        child: const Icon(Icons.access_time, color: Color(0xFFE65100), size: 20),
                      ),
                      label: 'Jam Operasional',
                      value: '08:00 – 16:00 WIB',
                    ),
                    _divider(),
                    _InfoRow(
                      iconWidget: _CircleIcon(
                        bgColor: const Color(0xFFF3E5F5),
                        child: const Icon(Icons.storefront, color: Color(0xFF6A1B9A), size: 20),
                      ),
                      label: 'Jenis Usaha',
                      value: 'Toko Refi Frozen Food',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── SOSIAL MEDIA ──
              _buildSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Sosial Media'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _SosmedTile( //Membuat tombol sosial media
                          icon: FontAwesomeIcons.whatsapp,
                          label: 'WhatsApp',
                          color: const Color(0xFF25D366),
                          bgColor: const Color(0xFFE8F5E9),
                          onTap: () => _launch('https://wa.me/6285755354846'),
                        ),
                        const SizedBox(width: 12),
                        _SosmedTile(
                          icon: FontAwesomeIcons.tiktok,
                          label: 'TikTok',
                          color: Colors.black87,
                          bgColor: const Color(0xFFF5F5F5),
                          onTap: () => _launch('https://www.tiktok.com/@refifrozenfood0?_r=1&_t=ZS-96qc5DL2wsv'),
                        ),
                        const SizedBox(width: 12),
                        _SosmedTile(
                          icon: FontAwesomeIcons.instagram,
                          label: 'Instagram',
                          color: const Color(0xFFE1306C),
                          bgColor: const Color(0xFFFCE4EC),
                          onTap: () => _launch('https://www.instagram.com/refi.frozenfood?igsh=MXNjODIyYzhiMWk3dg=='),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── PETA LOKASI ──
              _buildSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionTitle('Lokasi Kami'),
                        GestureDetector(
                          onTap: () => _launch(
                            'https://maps.app.goo.gl/WNEjoteVoYREPx6S8?g_st=ac',
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEEDFE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.open_in_new, size: 12, color: kPrimary),
                                SizedBox(width: 4),
                                Text(
                                  'Buka Maps',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: kPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: SizedBox(
                            width: double.infinity,
                            height: 170,
                            child: FlutterMap( //Menampilkan peta.
                              options: const MapOptions( // buat maps
                                initialCenter: LatLng(-7.5631, 111.9187), //Menentukan koordinat toko.
                                initialZoom: 15, //Mengatur tingkat dekat peta.
                                interactionOptions: InteractionOptions(
                                  flags: InteractiveFlag.none,
                                ),
                              ),
                              children: [
                                TileLayer( //mengabil gambar peta internet
                                  urlTemplate:
                                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                                  subdomains: const ['a', 'b', 'c', 'd'],
                                  userAgentPackageName: 'com.example.app',
                                ),
                                MarkerLayer( //Menampilkan penanda lokasi.
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
                        Positioned.fill(
                          child: GestureDetector( //Mendeteksi sentuhan/klik, Dipakai: Klik map saat di tekan launchUrl()
                            onTap: () async {
                              final geoUri = Uri.parse( //maps terbuka
                                'geo:-7.5631,111.9187?q=-7.5631,111.9187(Refi+Frozen+Food)',
                              );
                              if (await canLaunchUrl(geoUri)) {
                                await launchUrl(geoUri);
                              } else {
                                final webUri = Uri.parse( //kalau gagal
                                  'https://www.google.com/maps/search/?api=1&query=-7.5631,111.9187',
                                );
                                await launchUrl(webUri, mode: LaunchMode.externalApplication);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kBlue),
    );
  }

  Widget _divider() => Divider(height: 1, thickness: 0.8, color: Colors.grey.shade100);

  Widget _buildSection({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4919B9).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ══════════════════════════════════════════════
//  WIDGET: INFO ROW
// ══════════════════════════════════════════════
class _InfoRow extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.iconWidget,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(value, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, color: Colors.black26, size: 16),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  WIDGET: ICON BULAT
// ══════════════════════════════════════════════
class _CircleIcon extends StatelessWidget {
  final Color bgColor;
  final Widget child;

  const _CircleIcon({required this.bgColor, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Center(child: child),
    );
  }
}

// ══════════════════════════════════════════════
//  WIDGET: SOSMED TILE
// ══════════════════════════════════════════════
class _SosmedTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _SosmedTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              FaIcon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}