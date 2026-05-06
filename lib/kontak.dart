import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const Color kPrimary    = Color(0xFF4919B9);
const Color kBackground = Color(0xFFF0F2FF);
const Color kBlue       = Color(0xFF1F21AA);
const Color kSurface    = Colors.white;

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── HEADER BANNER ────────────────────────────
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'HUBUNGI KAMI',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Refi Frozen Food',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Jl. Dahlia No.II, Ds. Warujayeng',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── CARD INFORMASI USAHA ─────────────────────
              _buildSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Informasi Usaha'),
                    const SizedBox(height: 12),
                    _InfoRow(
                      iconWidget: _CircleIcon(
                        bgColor: const Color(0xFFEEEDFE),
                        child: const Icon(Icons.location_on,
                            color: kPrimary, size: 20),
                      ),
                      label: 'Alamat',
                      value: 'Jl. Dahlia No.II, Ds. Warujayeng',
                    ),
                    _divider(),
                    _InfoRow(
                      iconWidget: _CircleIcon(
                        bgColor: const Color(0xFFE8F5E9),
                        child: const Icon(Icons.phone,
                            color: Color(0xFF2E7D32), size: 20),
                      ),
                      label: 'No. Telepon',
                      value: '0857-5535-4846',
                    ),
                    _divider(),
                    _InfoRow(
                      iconWidget: _CircleIcon(
                        bgColor: const Color(0xFFFFF3E0),
                        child: const Icon(Icons.access_time,
                            color: Color(0xFFE65100), size: 20),
                      ),
                      label: 'Jam Operasional',
                      value: '08:00 – 16:00 WIB',
                    ),
                    _divider(),
                    _InfoRow(
                      iconWidget: _CircleIcon(
                        bgColor: const Color(0xFFF3E5F5),
                        child: const Icon(Icons.storefront,
                            color: Color(0xFF6A1B9A), size: 20),
                      ),
                      label: 'Jenis Usaha',
                      value: 'Toko Refi Frozen Food',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── CARD SOSIAL MEDIA ────────────────────────
              _buildSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Sosial Media'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _SosmedTile(
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
                          onTap: () => _launch(
                              'https://www.tiktok.com/@refifrozenfood0?_r=1&_t=ZS-94d3UiEUoFk'),
                        ),
                        const SizedBox(width: 12),
                        _SosmedTile(
                          icon: FontAwesomeIcons.instagram,
                          label: 'Instagram',
                          color: const Color(0xFFE1306C),
                          bgColor: const Color(0xFFFCE4EC),
                          onTap: () => _launch(
                              'https://www.instagram.com/refi_frozenfood_warujayeng?igsh=MThyMWViNXNpeXhhZA=='),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── CARD LOKASI PETA ─────────────────────────
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
                              'https://maps.app.goo.gl/xV5jJo9WZhq1RPvm8?g_st=aw'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEEDFE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.open_in_new,
                                    size: 12, color: kPrimary),
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
                    GestureDetector(
                      onTap: () => _launch(
                          'https://maps.app.goo.gl/xV5jJo9WZhq1RPvm8?g_st=aw'),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: double.infinity,
                          height: 170,
                          child: FlutterMap(
                            options: const MapOptions(
                              initialCenter: LatLng(-7.5631, 111.9187),
                              initialZoom: 15,
                              interactionOptions: InteractionOptions(
                                flags: InteractiveFlag.none,
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.app',
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
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: kBlue,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _divider() => Divider(
      height: 1, thickness: 0.8, color: Colors.grey.shade100);

  Widget _buildSection({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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

// ── Widget Pembantu ───────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _InfoRow(
      {required this.iconWidget,
      required this.label,
      required this.value,
      this.onTap});

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
                  Text(label,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right,
                  color: Colors.black26, size: 16),
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
      width: 42,
      height: 42,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Center(child: child),
    );
  }
}

// Sosmed tile versi card — lebih modern dari circle hitam polos
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
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}