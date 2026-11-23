// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../sidebar.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key, this.loadDashboard});

  final Future<DashboardData> Function({
    String? tanggalAwal,
    String? tanggalAkhir,
  })?
  loadDashboard;

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  static const _navy = Color(0xFF17345C);
  static const _blue = Color(0xFF168BFA);
  static const _background = Color(0xFFF4F7FB);

  late DateTime _selectedMonth;
  late Future<DashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    _dashboardFuture = _fetchDashboard();
  }

  Future<DashboardData> _fetchDashboard() {
    final start = DateTime(_selectedMonth.year, _selectedMonth.month);
    final end = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    String apiDate(DateTime date) =>
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    return (widget.loadDashboard ?? ApiService.instance.getDashboard)(
      tanggalAwal: apiDate(start),
      tanggalAkhir: apiDate(end),
    );
  }

  void _reloadDashboard() {
    setState(() => _dashboardFuture = _fetchDashboard());
  }

  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'PILIH BULAN LAPORAN',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _blue,
            onPrimary: Colors.white,
            onSurface: _navy,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _selectedMonth = DateTime(picked.year, picked.month);
      _dashboardFuture = _fetchDashboard();
    });
  }

  Map<String, dynamic> _summary(Map<String, dynamic> raw) {
    for (final key in ['summary', 'ringkasan', 'counts', 'statistik']) {
      final value = raw[key];
      if (value is Map) return Map<String, dynamic>.from(value);
    }
    return raw;
  }

  String _value(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return '—';
  }

  List<Map<String, dynamic>> _list(
    Map<String, dynamic> raw,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = raw[key];
      if (value is List) {
        return value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    return const [];
  }

  String _monthLabel(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      drawer: const AdminSidebar(),
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 4,
        title: const Text(
          'Dashboard Komplain',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _reloadDashboard,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<DashboardData>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            final raw = snapshot.data?.raw ?? const <String, dynamic>{};
            final summary = _summary(raw);
            return RefreshIndicator(
              color: _blue,
              onRefresh: () async {
                final future = _fetchDashboard();
                setState(() => _dashboardFuture = future);
                await future;
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                children: [
                  _buildIntroCard(),
                  const SizedBox(height: 20),
                  _buildPeriodSelector(),
                  const SizedBox(height: 18),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 38),
                      child: Center(
                        child: CircularProgressIndicator(color: _blue),
                      ),
                    )
                  else if (snapshot.hasError)
                    _buildErrorCard(snapshot.error)
                  else ...[
                    _buildStatistics(summary),
                    const SizedBox(height: 24),
                    _buildTechnicianSection(
                      title: 'Performa Teknisi',
                      subtitle: _monthLabel(_selectedMonth),
                      icon: Icons.insights_rounded,
                      entries: _list(raw, [
                        'performance',
                        'performa_teknisi',
                        'teknisi_performance',
                      ]),
                      isRanking: false,
                    ),
                    const SizedBox(height: 16),
                    _buildTechnicianSection(
                      title: 'Ranking Teknisi Bulanan',
                      subtitle: _monthLabel(_selectedMonth),
                      icon: Icons.emoji_events_rounded,
                      entries: _list(raw, [
                        'ranking',
                        'ranking_teknisi',
                        'technician_ranking',
                      ]),
                      isRanking: true,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'RSAB Harapan Kita · Layanan dan Monitoring IT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blueGrey.shade400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [_navy, Color(0xFF2377C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PUSAT MONITORING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Dashboard Monitoring,\nKomplain IT.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    height: 1.18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Ringkasan statistik komplain dan performa teknisi pada bulan yang dipilih.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Periode laporan',
                style: TextStyle(
                  color: _navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Data komplain berdasarkan bulan',
                style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 11),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: _selectMonth,
          icon: const Icon(Icons.calendar_month_rounded, size: 17),
          label: Text(_monthLabel(_selectedMonth)),
          style: OutlinedButton.styleFrom(
            foregroundColor: _navy,
            side: const BorderSide(color: Color(0xFFDCE5EF)),
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(Map<String, dynamic> data) {
    final cards = [
      _Statistic(
        title: 'Dibuat',
        value: _value(data, ['dibuat', 'total_dibuat', 'created']),
        icon: Icons.note_add_rounded,
        color: const Color(0xFF168BFA),
      ),
      _Statistic(
        title: 'Diproses',
        value: _value(data, [
          'proses',
          'diproses',
          'total_proses',
          'in_progress',
        ]),
        icon: Icons.settings_rounded,
        color: const Color(0xFF7657E8),
      ),
      _Statistic(
        title: 'Pending',
        value: _value(data, ['pending', 'total_pending']),
        icon: Icons.schedule_rounded,
        color: const Color(0xFFEC9B19),
      ),
      _Statistic(
        title: 'Menunggu ulasan',
        value: _value(data, [
          'menunggu_ulasan',
          'total_menunggu_ulasan',
          'awaiting_review',
        ]),
        icon: Icons.rate_review_rounded,
        color: const Color(0xFF20B981),
      ),
      _Statistic(
        title: 'Selesai',
        value: _value(data, ['selesai', 'total_selesai', 'completed']),
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF17345C),
      ),
      _Statistic(
        title: 'Total periode',
        value: _value(data, ['total', 'total_periode', 'total_komplain']),
        icon: Icons.calculate_rounded,
        color: const Color(0xFF168BFA),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map(
                (card) => SizedBox(
                  width: itemWidth,
                  child: _StatisticCard(statistic: card),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildTechnicianSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Map<String, dynamic>> entries,
    required bool isRanking,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EEF5)),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: isRanking ? const Color(0xFFEC9B19) : _blue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.only(left: 27),
              child: Text(
                subtitle,
                style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 11),
              ),
            ),
            const SizedBox(height: 14),
            _buildTechnicianTable(entries, isRanking),
            if (entries.isEmpty)
              _buildEmptyState(
                isRanking
                    ? 'Belum ada data ranking untuk bulan ini.'
                    : 'Belum ada data komplain selesai bulan ini.',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicianTable(
    List<Map<String, dynamic>> entries,
    bool isRanking,
  ) {
    final columns = isRanking
        ? [
            ('Rank', 58.0),
            ('Nama Teknisi', 150.0),
            ('Total Selesai', 108.0),
            ('Target', 82.0),
            ('Persentase', 94.0),
            ('Capaian', 94.0),
            ('Progress', 110.0),
          ]
        : [
            ('No', 44.0),
            ('Nama Teknisi', 140.0),
            ('Total Selesai', 100.0),
            ('Rating Rata-rata', 112.0),
            ('Jumlah Ulasan', 100.0),
            ('Proses < 15 Menit', 122.0),
            ('Proses ≥ 15 Menit', 122.0),
            ('Selesai < 30 Menit', 122.0),
            ('Selesai ≥ 30 Menit', 122.0),
          ];
    final tableWidth = columns.fold<double>(
      0,
      (width, column) => width + column.$2,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: tableWidth,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE9EEF5))),
              ),
              child: Row(
                children: columns
                    .map(
                      (column) => SizedBox(
                        width: column.$2,
                        child: Text(
                          column.$1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.blueGrey.shade500,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            ...entries.asMap().entries.map(
              (entry) => _buildTechnicianRow(
                entry.value,
                entry.key + 1,
                isRanking,
                columns,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicianRow(
    Map<String, dynamic> entry,
    int rank,
    bool isRanking,
    List<(String, double)> columns,
  ) {
    final values = isRanking
        ? [
            entry['rank']?.toString() ??
                entry['peringkat']?.toString() ??
                '$rank',
            _value(entry, ['nama_teknisi', 'teknisi', 'name', 'nama']),
            _value(entry, [
              'total_selesai',
              'selesai',
              'jumlah_selesai',
              'total',
            ]),
            _value(entry, ['target', 'target_bulanan']),
            _value(entry, ['persentase', 'percentage', 'persentase_capaian']),
            _value(entry, ['capaian', 'achievement']),
            _value(entry, ['progress', 'kemajuan']),
          ]
        : [
            '$rank',
            _value(entry, ['nama_teknisi', 'teknisi', 'name', 'nama']),
            _value(entry, [
              'total_selesai',
              'selesai',
              'jumlah_selesai',
              'total',
            ]),
            _value(entry, [
              'rating_rata_rata',
              'rating_rata',
              'average_rating',
              'rating',
            ]),
            _value(entry, ['jumlah_ulasan', 'ulasan', 'reviews']),
            _value(entry, [
              'proses_kurang_15_menit',
              'proses_lt_15_menit',
              'proses_under_15_minutes',
              'proses_15_menit',
            ]),
            _value(entry, [
              'proses_lebih_dari_15_menit',
              'proses_gte_15_menit',
              'proses_over_15_minutes',
              'proses_lebih_15_menit',
            ]),
            _value(entry, [
              'selesai_kurang_30_menit',
              'selesai_lt_30_menit',
              'completed_under_30_minutes',
              'selesai_30_menit',
            ]),
            _value(entry, [
              'selesai_lebih_dari_30_menit',
              'selesai_gte_30_menit',
              'completed_30_minutes_or_more',
              'selesai_lebih_30_menit',
            ]),
          ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F3F7))),
      ),
      child: Row(
        children: List.generate(
          columns.length,
          (index) => SizedBox(
            width: columns[index].$2,
            child: Text(
              values[index],
              textAlign: index == 1 ? TextAlign.left : TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: index == 1 ? _navy : Colors.blueGrey.shade600,
                fontSize: 11,
                fontWeight: index == 1 ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 19),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, color: Colors.blueGrey.shade300, size: 24),
          const SizedBox(height: 7),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(Object? error) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF2D3D3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Color(0xFFDC5454),
            size: 30,
          ),
          const SizedBox(height: 9),
          const Text(
            'Data dashboard belum dapat dimuat',
            style: TextStyle(
              color: _navy,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            error is ApiException ? error.message : '$error',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 11),
          ),
          const SizedBox(height: 13),
          FilledButton.icon(
            onPressed: _reloadDashboard,
            icon: const Icon(Icons.refresh_rounded, size: 17),
            label: const Text('Coba lagi'),
            style: FilledButton.styleFrom(
              backgroundColor: _blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Statistic {
  const _Statistic({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}

class _StatisticCard extends StatelessWidget {
  const _StatisticCard({required this.statistic});

  final _Statistic statistic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: statistic.color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: statistic.color.withValues(alpha: 0.045),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: statistic.color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(statistic.icon, color: statistic.color, size: 17),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_outward_rounded,
                color: statistic.color.withValues(alpha: 0.55),
                size: 15,
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            statistic.value,
            style: TextStyle(
              color: statistic.color,
              fontSize: 24,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            statistic.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.blueGrey.shade600,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
