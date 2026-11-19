import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../req_komplain/form.dart';

class DashboardReqPage extends StatefulWidget {
  const DashboardReqPage({super.key});

  @override
  State<DashboardReqPage> createState() => _DashboardReqPageState();
}

class _DashboardReqPageState extends State<DashboardReqPage> {
  // Controller Filter
  final TextEditingController namaController = TextEditingController();
  DateTime? tanggalAwal;
  DateTime? tanggalAkhir;
  String? selectedStatus;
  String? selectedRuangan;
  final List<Map<String, dynamic>> _apiStatuses = [];
  List<String>? _apiRuangans;
  Map<String, dynamic> _dashboardSummary = {};
  bool _isLoadingTickets = true;
  String? _dashboardError;
  String? _optionsError;
  String? _ticketError;
  Timer? _filterDebounce;

  final List<String> listStatus = [
    'Dibuat',
    'Proses',
    'Pending',
    'Beri Ulasan',
    'Batal',
    'Selesai TL',
    'Selesai',
  ];

  final List<String> listRuangan = [
    'Semua Ruangan',
    'Ruang Tanjung',
    'Ruang Teratai',
    'Ruang Widuri',
    'Laboratorium',
    'FarmasiKlinik Terpadu Laktasi',
    'Klinik Terpadu Remaja',
    'Klinik Eksekutif Gigi Anak',
    'Laboratorium Patologi Klinik',
    'Klinik False Emergency',
    'Ruang Gambir',
    'Klinik Ginekologi',
    'Klinik Umroh dan Haji Terpadu',
    'Klinik Terpadu Kontrasepsi',
    'Klinik Genetika Klinik',
    'Klinik Gigi Ortodonti',
    'Klinik Eksekutif Gigi dan Mulut Umum',
    'Klinik Eksekutif Gigi Ortodonti',
    'Klinik Eksekutif Gigi Konservasi',
    'Klinik Terpadu Intervensi Pra Natal',
    'Klinik Terpadu Edukasi Keluarga',
    'Klinik Terpadu Kembar Siam',
    'Pusat Kelainan Bawaan Lahir Terpadu/Birth Defects Integrated Center (BIDIC)',
    'Klinik Terpadu Geriatri',
    'Klinik Terpadu Perempuan Sehat (KLIPS)',
    'Klinik Vaksinasi Terpadu',
    'Unit Pendidikan dan Pelatihan',
    'Lab. Sitogenetika dan Genetika Molekular',
    'CathLab',
    'Klinik Eksekutif Gigi Periodonsia',
    'g IBS - Post Anesthesia Care Unit (PACU)',
    'Ruang IBS - Pusat Diagnostik',
    'Klinik Eksekutif Gigi Penyakit Mulut',
    'Klinik Gigi Penyakit Mulut',
    'Klinik Gigi Periodonsia',
    'Klinik Gigi Prostodonsia',
    'Klinik Pinere',
    'Klinik Konseling Gizi',
    'Klinik Eksekutif Fetal Echo',
    'Poli Kebidanan Klinik Utama',
    'Poli Anak Klinik Utama',
    'Terapi Sensori Integrasi Klinik Utama',
    'Terapi Okupasi Klinik Utama',
    'Terapi Wicara Klinik Utama',
    'Fisioterapi Klinik Utama',
    'Klinik Utama Bintaro',
    'RAK',
    'Inst. Penelitian Pusat Inisiatif Sekuensing Geom dan Biomedis',
    'Okupasi Terapi',
    'Bag. Informasi & Rekam Medik',
    'Ruang Melati',
    'Klinik Eksekutif Akupuntur',
    'Gudang Farmasi non Persediaan',
    'Farmasi Edelweis',
    'Ruang Produksi Gizi',
    'Kelompok Staf Medik Anak',
    'Staf Medik Fungsional Kebidanan',
    'Kelompok Staf Medik Bedah',
    'Gudang Bagian Umum',
    'Gudang Pinjaman',
    'Depo Farmasi Amarylis',
    'CSSD',
    'Gudang Terminal Gizi',
    'Gudang Terminal Laundry & CSSD',
    'Sarana Sandang dan Sterilisasi Sentral',
    'Inst. Prasarana Dan Sarana RS',
    'Kepala Subbagian Diklat Kesehatan',
    'Kepala Subbagian Diklat Non Kesehatan',
    'Kepala Subbagian Evaluasi Anggaran',
    'Ambulan',
    'Asrama Lantai VII',
    'Rawat Jalan Anak Administrasi Ruangan',
    'Instalasi Perinatal Terpadu dan Rujukan',
    'Kelompok Staf Medik Dokter Umum',
    'Kelompok Staf Medik Gigi dan Mulut',
    'Kelompok Staf Medik Kebidanan',
    'Kelompok Staf Medik Spesialis Lain',
    'Sekretaris Dewas',
    'Rawat Jalan Ibu Administrasi Ruangan',
    'IP3RS',
    'Farmasi 1',
    'Farmasi 2',
    'Farmasi 3 OK',
    'Farmasi 4',
    'Farmasi 9',
    'FARMASI 06',
    'Farmasi Steril Rawat Inap',
  ];

  List<Map<String, dynamic>> displayedTiketList = [];
  bool isSortedAscending = true;

  @override
  void initState() {
    super.initState();
    _loadRemoteData();
  }

  @override
  void dispose() {
    _filterDebounce?.cancel();
    namaController.dispose();
    super.dispose();
  }

  void _scheduleFilter() {
    _filterDebounce?.cancel();
    _filterDebounce = Timer(
      const Duration(milliseconds: 400),
      () => applyFilter(),
    );
  }

  Future<void> _loadRemoteData() async {
    try {
      final dashboard = await ApiService.instance.getDashboard();
      if (mounted) setState(() => _dashboardSummary = dashboard.raw);
    } on ApiException catch (e) {
      if (mounted) setState(() => _dashboardError = e.message);
    } catch (e) {
      if (mounted) {
        setState(() => _dashboardError = 'Gagal memuat ringkasan: $e');
      }
    }

    try {
      final options = await ApiService.instance.getOptions();
      if (mounted) {
        setState(() {
          _apiStatuses
            ..clear()
            ..addAll(options.statuses);
          _apiRuangans = options.ruangans;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _optionsError = e.message);
    } catch (e) {
      if (mounted) setState(() => _optionsError = 'Gagal memuat pilihan: $e');
    }

    await applyFilter(showError: false);
  }

  // Fungsi Filter
  Future<void> applyFilter({bool showError = true}) async {
    if (!mounted) return;
    final queryNama = namaController.text.trim().toLowerCase();
    final selectedStatusId = _statusIdFor(selectedStatus);
    final dateStart = tanggalAwal == null ? null : _apiDate(tanggalAwal!);
    final dateEnd = tanggalAkhir == null ? null : _apiDate(tanggalAkhir!);

    setState(() {
      _isLoadingTickets = true;
    });
    try {
      final result = await ApiService.instance.getKomplainList(
        search: queryNama.isEmpty ? null : queryNama,
        statusId: selectedStatusId,
        unitKerja: selectedRuangan == null || selectedRuangan == 'Semua Ruangan'
            ? null
            : selectedRuangan,
        tanggalAwal: dateStart,
        tanggalAkhir: dateEnd,
        page: 1,
        perPage: 50,
      );
      final items = result.items.map(_toTableItem).toList();
      if (!mounted) return;
      setState(() {
        displayedTiketList = items;
        _ticketError = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _ticketError = e.message);
      if (showError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _ticketError = 'Gagal memuat data komplain: $e');
      if (showError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data komplain: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingTickets = false);
    }
  }

  int? _statusIdFor(String? label) {
    if (label == null || label == 'Semua Status') return null;
    for (final status in _apiStatuses) {
      final name = _value(status, const ['name', 'nama', 'label', 'status']);
      if (name.toLowerCase() == label.toLowerCase()) {
        final id = status['id'] ?? status['status_id'];
        return int.tryParse(id?.toString() ?? '');
      }
    }
    return null;
  }

  String _apiDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  String _value(
    Map<String, dynamic> item,
    List<String> keys, [
    String fallback = '-',
  ]) {
    for (final key in keys) {
      final value = item[key];
      if (value is Map) {
        final nested = value['name'] ?? value['nama'] ?? value['label'];
        if (nested != null && nested.toString().isNotEmpty) {
          return nested.toString();
        }
      } else if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  Map<String, dynamic> _toTableItem(KomplainItem item) {
    final raw = item.raw;
    final dateValue = _value(raw, const [
      'created_at',
      'tanggal',
      'tanggal_dibuat',
    ], '');
    return {
      'noTiket': _value(raw, const ['ticket_no', 'no_tiket', 'ticketNo']),
      'namaPengusul': _value(raw, const [
        'pic_internal',
        'pic_eksternal',
        'pic',
        'nama_pengusul',
      ]),
      'ruangan': _value(raw, const [
        'unit_kerja_internal',
        'lokasi_external',
        'unit_kerja',
        'ruangan',
      ]),
      'kategori': _value(raw, const ['permintaan', 'kategori']),
      'kerusakan': _value(raw, const ['kerusakan', 'judul_kerusakan']),
      'teknisi': _value(raw, const ['teknisi', 'nama_teknisi']),
      'status': _value(raw, const ['status', 'status_name', 'nama_status']),
      'tanggal': DateTime.tryParse(dateValue),
      'keterangan': item.keterangan,
    };
  }

  // Reset Filter
  Future<void> resetFilter() async {
    setState(() {
      namaController.clear();
      tanggalAwal = null;
      tanggalAkhir = null;
      selectedStatus = null;
      selectedRuangan = null;
    });
    await applyFilter();
  }

  // Format Tanggal
  String formatDate(DateTime? dt) {
    if (dt == null) return 'mm/dd/yyyy';
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$m/$d/${dt.year}';
  }

  // Pilih Tanggal
  Future<void> pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (tanggalAwal ?? DateTime.now())
          : (tanggalAkhir ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0090FF),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          tanggalAwal = picked;
        } else {
          tanggalAkhir = picked;
        }
      });
    }
  }

  // Warna Badge Status
  Color getStatusBgColor(String status) {
    switch (status) {
      case 'Selesai':
        return const Color(0xFFDCFCE7);
      case 'Diproses':
        return const Color(0xFFE0F2FE);
      case 'Menunggu':
        return const Color(0xFFFEF3C7);
      case 'Ditolak':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color getStatusTextColor(String status) {
    switch (status) {
      case 'Selesai':
        return const Color(0xFF16A34A);
      case 'Diproses':
        return const Color(0xFF0284C7);
      case 'Menunggu':
        return const Color(0xFFD97706);
      case 'Ditolak':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF475569);
    }
  }

  // Dialog Detail Tiket
  void showDetailDialog(Map<String, dynamic> item) {
    final detailFuture = ApiService.instance.getKomplainStatus(
      item['noTiket'].toString(),
    );
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<TicketDetail>(
        future: detailFuture,
        builder: (context, snapshot) {
          final detail = snapshot.data?.detail ?? {};
          String read(List<String> keys, String fallback) {
            for (final key in keys) {
              final value = detail[key];
              if (value != null && value.toString().isNotEmpty) {
                if (value is Map) {
                  final nested =
                      value['name'] ?? value['nama'] ?? value['label'];
                  if (nested != null) return nested.toString();
                } else {
                  return value.toString();
                }
              }
            }
            return fallback;
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.confirmation_number_outlined,
                  color: Color(0xFF0090FF),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item['noTiket'].toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            content: snapshot.connectionState == ConnectionState.waiting
                ? const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : snapshot.hasError
                ? Text('Gagal memuat detail tiket: ${snapshot.error}')
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildDetailRow(
                          'Nama Pengusul',
                          read(const [
                            'pic_internal',
                            'pic_eksternal',
                            'pic',
                          ], item['namaPengusul'].toString()),
                        ),
                        buildDetailRow(
                          'Ruangan',
                          read(const [
                            'unit_kerja_internal',
                            'lokasi_external',
                            'unit_kerja',
                          ], item['ruangan'].toString()),
                        ),
                        buildDetailRow(
                          'Kategori Komplain',
                          read(const [
                            'permintaan',
                            'kategori',
                          ], item['kategori'].toString()),
                        ),
                        buildDetailRow(
                          'Kerusakan',
                          read(const [
                            'kerusakan',
                          ], item['kerusakan'].toString()),
                        ),
                        buildDetailRow(
                          'Teknisi',
                          read(const [
                            'teknisi',
                            'nama_teknisi',
                          ], item['teknisi'].toString()),
                        ),
                        buildDetailRow(
                          'Status',
                          read(const [
                            'status',
                            'status_name',
                            'nama_status',
                          ], item['status'].toString()),
                        ),
                        buildDetailRow(
                          'Tanggal Dibuat',
                          read(const [
                            'created_at',
                            'tanggal',
                          ], formatDate(item['tanggal'])),
                        ),
                        buildDetailRow(
                          'Keterangan',
                          read(const [
                            'keterangan',
                          ], item['keterangan'].toString()),
                        ),
                        if (snapshot.data!.history.isNotEmpty) ...[
                          const Divider(height: 24),
                          const Text(
                            'Histori Tiket',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...snapshot.data!.history.map((entry) {
                            final status =
                                entry['status'] ??
                                entry['status_name'] ??
                                entry['nama_status'] ??
                                'Pembaruan';
                            final note =
                                entry['keterangan'] ?? entry['catatan'] ?? '';
                            final date =
                                entry['created_at'] ?? entry['tanggal'] ?? '';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                [status, date, note]
                                    .where(
                                      (value) => value.toString().isNotEmpty,
                                    )
                                    .join(' • '),
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0090FF),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tutup'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Daftar Komplain IT',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF0090FF),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Logo & Judul sesuai gambar
              buildHeaderLogo(),

              if (_dashboardSummary.isNotEmpty) ...[
                const SizedBox(height: 16),
                buildSummaryCard(),
              ],

              if ([
                _dashboardError,
                _optionsError,
                _ticketError,
              ].any((error) => error != null)) ...[
                const SizedBox(height: 12),
                Text(
                  [
                    _dashboardError,
                    _optionsError,
                    _ticketError,
                  ].whereType<String>().join('\n'),
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],

              const SizedBox(height: 16),

              // Filter Card
              buildFilterCard(),

              const SizedBox(height: 16),

              // Tabel Data Komplain
              buildTableCard(),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Header Logo Kemenkes RSAB Harapan Kita
  Widget buildHeaderLogo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo Kemenkes RSAB Harapan Kita persis di atas Daftar Komplain IT
          Image.asset(
            'assets/icons/logo-fullname.png',
            height: 50,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'web/icons/logo-fullname.png',
                height: 50,
                fit: BoxFit.contain,
              );
            },
          ),

          const SizedBox(height: 14),

          // Judul & Subjudul
          const Text(
            'Daftar Komplain IT',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Sistem Pelaporan dan Monitoring Komplain IT',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildSummaryCard() {
    final metrics = <MapEntry<String, String>>[];
    void collect(String prefix, Object? value) {
      if (value is Map) {
        value.forEach((key, nestedValue) {
          collect(
            prefix.isEmpty ? key.toString() : '$prefix · $key',
            nestedValue,
          );
        });
      } else if (value is num || value is String || value is bool) {
        metrics.add(MapEntry(prefix, value.toString()));
      }
    }

    _dashboardSummary.forEach((key, value) => collect(key, value));
    if (metrics.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Permintaan dan Komplain',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: metrics.take(8).map((metric) {
              return SizedBox(
                width: 145,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric.key,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      metric.value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0090FF),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 2. Card Filter
  Widget buildFilterCard() {
    final apiStatusNames = _apiStatuses
        .map(
          (status) =>
              _value(status, const ['name', 'nama', 'label', 'status'], ''),
        )
        .where((status) => status.isNotEmpty)
        .toSet()
        .toList();
    final statusOptions = apiStatusNames.isEmpty ? listStatus : apiStatusNames;
    final ruanganOptions = _apiRuangans == null
        ? listRuangan
        : ['Semua Ruangan', ..._apiRuangans!];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Tambahan: Nama Pengusul (sesuai permintaan user)
          buildFieldLabel('Nama Pengusul'),
          TextFormField(
            controller: namaController,
            decoration: inputDecoration(
              'Cari nama pengusul...',
              Icons.person_outline,
            ),
            onChanged: (_) => _scheduleFilter(),
          ),

          const SizedBox(height: 14),

          // Filter Tanggal Awal & Tanggal Akhir
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildFieldLabel('Tanggal Awal'),
                    InkWell(
                      onTap: () => pickDate(isStart: true),
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                formatDate(tanggalAwal),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: tanggalAwal == null
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF1E293B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: Color(0xFF64748B),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildFieldLabel('Tanggal Akhir'),
                    InkWell(
                      onTap: () => pickDate(isStart: false),
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                formatDate(tanggalAkhir),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: tanggalAkhir == null
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF1E293B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: Color(0xFF64748B),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Filter Status & Unit Kerja (Ruangan)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildFieldLabel('Status'),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      hint: const Text(
                        'Pilih Status',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      decoration: dropdownDecoration(),
                      isExpanded: true,
                      items: statusOptions.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(
                            status,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedStatus = val;
                        });
                        applyFilter();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildFieldLabel('Unit Kerja'),
                    DropdownButtonFormField<String>(
                      value: selectedRuangan,
                      hint: const Text(
                        'Pilih Ruangan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      decoration: dropdownDecoration(),
                      isExpanded: true,
                      items: ruanganOptions.map((ruangan) {
                        return DropdownMenuItem(
                          value: ruangan,
                          child: Text(
                            ruangan,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedRuangan = val;
                        });
                        applyFilter();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Tombol Filter: Cari, Reset, + Buat Komplain Baru
          Row(
            children: [
              // Tombol Cari (Biru)
              ElevatedButton.icon(
                onPressed: applyFilter,
                icon: const Icon(Icons.search, size: 16),
                label: const Text(
                  'Cari',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0090FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Tombol Reset
              OutlinedButton(
                onPressed: resetFilter,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Reset', style: TextStyle(fontSize: 13)),
              ),

              const Spacer(),

              // Tombol + Buat Komplain Baru (Hijau)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KomplainFormPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  ' Buat Baru',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF10B981,
                  ), // Warna hijau sesuai gambar
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Card Tabel Komplain IT
  Widget buildTableCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Tabel Info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Data Komplain (${displayedTiketList.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Row(
                  children: [
                    Icon(Icons.swipe, size: 14, color: Color(0xFF94A3B8)),
                    SizedBox(width: 4),
                    Text(
                      'Geser tabel >>',
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Tabel Horizontal Scrollable
          if (_isLoadingTickets)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),

          if (displayedTiketList.isEmpty && !_isLoadingTickets)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Tidak ada data komplain yang sesuai',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF8FAFC),
                ),
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF334155),
                ),
                dataTextStyle: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1E293B),
                ),
                horizontalMargin: 16,
                columnSpacing: 18,
                sortColumnIndex: 0,
                sortAscending: isSortedAscending,
                columns: [
                  DataColumn(
                    label: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Nomor Tiket'),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_upward,
                          size: 12,
                          color: Color(0xFF64748B),
                        ),
                      ],
                    ),
                    onSort: (columnIndex, ascending) {
                      setState(() {
                        isSortedAscending = !isSortedAscending;
                        displayedTiketList.sort((a, b) {
                          return isSortedAscending
                              ? (a['noTiket'] as String).compareTo(
                                  b['noTiket'] as String,
                                )
                              : (b['noTiket'] as String).compareTo(
                                  a['noTiket'] as String,
                                );
                        });
                      });
                    },
                  ),
                  const DataColumn(label: Text('Nama Pengusul')),
                  const DataColumn(label: Text('Ruangan')),
                  const DataColumn(label: Text('Kategori Komplain')),
                  const DataColumn(label: Text('Kerusakan')),
                  const DataColumn(label: Text('Teknisi')),
                  const DataColumn(label: Text('Status')),
                  const DataColumn(label: Text('Tanggal Dibuat')),
                  const DataColumn(label: Text('Keterangan')),
                  const DataColumn(label: Text('#')),
                ],
                rows: displayedTiketList.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          item['noTiket'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0090FF),
                          ),
                        ),
                        onTap: () => showDetailDialog(item),
                      ),
                      DataCell(Text(item['namaPengusul'])),
                      DataCell(Text(item['ruangan'])),
                      DataCell(Text(item['kategori'])),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: Text(
                            item['kerusakan'],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(item['teknisi'])),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: getStatusBgColor(item['status']),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item['status'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: getStatusTextColor(item['status']),
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(formatDate(item['tanggal']))),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 180),
                          child: Text(
                            item['keterangan'],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(
                            Icons.remove_red_eye_outlined,
                            size: 18,
                            color: Color(0xFF0090FF),
                          ),
                          tooltip: 'Lihat Detail',
                          onPressed: () => showDetailDialog(item),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      isDense: true,
      filled: true,
      fillColor: Colors.white,
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
    );
  }

  InputDecoration dropdownDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      isDense: true,
      filled: true,
      fillColor: Colors.white,
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
    );
  }
}
