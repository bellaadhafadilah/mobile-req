import 'package:flutter/material.dart';

import '../services/api_service.dart';

class CekStatusPage extends StatefulWidget {
  const CekStatusPage({super.key});

  @override
  State<CekStatusPage> createState() => _CekStatusPageState();
}

class _CekStatusPageState extends State<CekStatusPage> {
  final TextEditingController trackingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? searchedCode;
  TicketDetail? ticketDetail;
  String? ticketType;
  bool isSearching = false;

  Future<void> submitTracking() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      setState(() {
        isSearching = true;
        searchedCode = null;
        ticketDetail = null;
        ticketType = null;
      });

      try {
        final code = trackingController.text.trim();
        late final TicketDetail result;
        late final String detectedType;
        try {
          result = await ApiService.instance.getPermintaanStatus(code);
          detectedType = 'Permintaan';
        } on ApiException catch (e) {
          if (e.statusCode != 404) rethrow;
          result = await ApiService.instance.getKomplainStatus(code);
          detectedType = 'Komplain';
        }
        if (!mounted) return;
        setState(() {
          searchedCode = code;
          ticketDetail = result;
          ticketType = detectedType;
          isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data tiket $code berhasil dimuat'),
            backgroundColor: const Color(0xFF0090FF),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } on ApiException catch (e) {
        if (!mounted) return;
        setState(() {
          ticketDetail = null;
          searchedCode = null;
          isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() {
          ticketDetail = null;
          searchedCode = null;
          isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal terhubung ke server: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card Utama Cek Status Permintaan sesuai gambar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Judul Cek Status Permintaan
                      Text(
                        ticketType == null
                            ? 'Cek Status Tiket'
                            : 'Cek Status $ticketType',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Input Field & Tombol Submit (Responsif Mobile)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Jika layar sangat sempit (di bawah 260px), tata letak dibuat vertikal
                          if (constraints.maxWidth < 260) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                buildTextField(),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 44,
                                  child: buildSubmitButton(),
                                ),
                              ],
                            );
                          }

                          // Tampilan sejajar sesuai referensi gambar
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: buildTextField()),
                              const SizedBox(width: 8),
                              SizedBox(height: 44, child: buildSubmitButton()),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Hasil Pencarian Status (jika sudah submit)
              if (searchedCode != null) ...[
                const SizedBox(height: 20),
                buildTrackingResultCard(),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFFF5F7FB),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0090FF),
                side: const BorderSide(color: Color(0xFF0090FF), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Kembali',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget Input Field Kode Tracking
  Widget buildTextField() {
    return TextFormField(
      controller: trackingController,
      decoration: InputDecoration(
        hintText: 'Masukkan Kode Tracking',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF0090FF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Masukkan kode tracking';
        }
        return null;
      },
    );
  }

  // Widget Tombol Submit Biru
  Widget buildSubmitButton() {
    return ElevatedButton(
      onPressed: isSearching ? null : submitTracking,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0090FF), // Warna biru sesuai gambar
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: isSearching
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Submit',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
    );
  }

  // Widget Tampilan Detail Status Hasil Tracking
  Widget buildTrackingResultCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status ${ticketType ?? 'Tiket'}',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '#$searchedCode',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _ticketValue(const [
                    'status',
                    'status_name',
                    'nama_status',
                  ], 'Status tidak tersedia'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          buildInfoRow(
            Icons.calendar_today_outlined,
            'Tanggal Pengajuan',
            _ticketValue(const ['created_at', 'tanggal', 'tanggal_pengajuan']),
          ),
          const SizedBox(height: 10),
          buildInfoRow(
            Icons.business_outlined,
            'Unit Kerja',
            _ticketValue(const [
              'unit_kerja',
              'unit_kerja_internal',
              'ruangan',
            ]),
          ),
          const SizedBox(height: 10),
          buildInfoRow(
            Icons.assignment_outlined,
            'Jenis Layanan',
            _ticketValue(const ['permintaan', 'jenis_permintaan']),
          ),
          const SizedBox(height: 10),
          buildInfoRow(
            Icons.info_outline,
            'Keterangan',
            _ticketValue(const ['keterangan', 'deskripsi']),
          ),
          if (ticketDetail?.history.isNotEmpty ?? false) ...[
            const Divider(height: 24),
            const Text(
              'Histori Tiket',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...ticketDetail!.history.map((item) {
              final status =
                  item['status'] ??
                  item['status_name'] ??
                  item['nama_status'] ??
                  'Pembaruan';
              final note = item['keterangan'] ?? item['catatan'] ?? '';
              final date = item['created_at'] ?? item['tanggal'] ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  [
                    status,
                    date,
                    note,
                  ].where((value) => value.toString().isNotEmpty).join(' • '),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  String _ticketValue(List<String> keys, [String fallback = 'Tidak tersedia']) {
    final detail = ticketDetail?.detail;
    for (final key in keys) {
      final value = detail?[key];
      if (value != null && value.toString().isNotEmpty) return value.toString();
    }
    return fallback;
  }

  Widget buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}