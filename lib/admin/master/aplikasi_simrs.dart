// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../../services/api_service.dart';

typedef AplikasiSimrsLoader = Future<AplikasiSimrsListResult> Function();

class AplikasiSimrsPage extends StatefulWidget {
  const AplikasiSimrsPage({super.key, this.loadApplications});

  final AplikasiSimrsLoader? loadApplications;

  @override
  State<AplikasiSimrsPage> createState() => _AplikasiSimrsPageState();
}

class _AplikasiSimrsPageState extends State<AplikasiSimrsPage> {
  static const _navy = Color(0xFF17345C);
  static const _blue = Color(0xFF168BFA);
  static const _background = Color(0xFFF4F7FB);

  static const _columns = [
    ('Nama', 150.0),
    ('Url', 210.0),
    ('Keterangan', 220.0),
    ('gambar', 160.0),
    ('Juknis', 160.0),
    ('#', 70.0),
  ];

  late Future<AplikasiSimrsListResult> _applicationsFuture;

  @override
  void initState() {
    super.initState();
    _applicationsFuture = _fetchApplications();
  }

  Future<AplikasiSimrsListResult> _fetchApplications() {
    return widget.loadApplications?.call() ??
        ApiService.instance.getAplikasiSimrsList();
  }

  void _reloadApplications() {
    setState(() => _applicationsFuture = _fetchApplications());
  }

  void _showAddNotice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'API mobile saat ini hanya mendukung membaca daftar aplikasi.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 4,
        title: const Text(
          'Aplikasi SIMRS',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang daftar aplikasi',
            onPressed: _reloadApplications,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<AplikasiSimrsListResult>(
          future: _applicationsFuture,
          builder: (context, snapshot) {
            final applications =
                snapshot.data?.items ?? const <Map<String, dynamic>>[];
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Daftar Aplikasi',
                        style: TextStyle(
                          color: _navy,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _showAddNotice(context),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Tambah'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTableCard(
                  applications: applications,
                  isLoading:
                      snapshot.connectionState == ConnectionState.waiting &&
                      snapshot.data == null,
                  error: snapshot.error,
                ),
                const SizedBox(height: 18),
                Text(
                  'Instalasi SIMRS · RSAB Harapan Kita',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontSize: 11,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, Color(0xFF24649C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.13),
            blurRadius: 16,
            offset: const Offset(0, 7),
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
                    color: Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'MASTER DATA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Halaman Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Kelola informasi aplikasi SIMRS.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.apps_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard({
    required List<Map<String, dynamic>> applications,
    required bool isLoading,
    Object? error,
  }) {
    const tableWidth = 970.0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6ECF3)),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FF),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.grid_view_rounded,
                    color: _blue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Data Aplikasi',
                    style: TextStyle(
                      color: _navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(
                  Icons.swipe_rounded,
                  size: 16,
                  color: Colors.blueGrey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  'Geser tabel',
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  _buildTableHeader(),
                  if (!isLoading && error == null)
                    ...applications.map(_buildApplicationRow),
                ],
              ),
            ),
          ),
          if (isLoading)
            _buildLoadingState()
          else if (error != null)
            _buildErrorState(error)
          else if (applications.isEmpty)
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(bottom: BorderSide(color: Color(0xFFE8EDF3))),
      ),
      child: Row(
        children: _columns
            .map(
              (column) => SizedBox(
                width: column.$2,
                child: Text(
                  column.$1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF52647A),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildApplicationRow(Map<String, dynamic> application) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F3F7))),
      ),
      child: Row(
        children: [
          _textCell(150, _value(application, 'nama_aplikasi')),
          _textCell(210, _value(application, 'url')),
          _textCell(220, _value(application, 'keterangan')),
          _imageCell(application['image_url']?.toString()),
          _manualCell(application['file_juknis_url']?.toString()),
          _textCell(70, _value(application, 'id')),
        ],
      ),
    );
  }

  Widget _textCell(double width, String value) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: _navy, fontSize: 11, height: 1.35),
        ),
      ),
    );
  }

  Widget _imageCell(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _textCell(160, '—');
    }

    return SizedBox(
      width: 160,
      height: 60,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Image.network(
            imageUrl,
            width: 52,
            height: 38,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.blueGrey,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _manualCell(String? manualUrl) {
    final available = manualUrl != null && manualUrl.isNotEmpty;
    return SizedBox(
      width: 160,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (available) ...[
              const Icon(Icons.picture_as_pdf_outlined, color: _blue, size: 16),
              const SizedBox(width: 4),
            ],
            Text(
              available ? 'Tersedia' : '—',
              style: TextStyle(
                color: available ? _blue : _navy,
                fontSize: 11,
                fontWeight: available ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _value(Map<String, dynamic> data, String key) {
    final value = data[key]?.toString().trim();
    return value == null || value.isEmpty ? '—' : value;
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Center(child: CircularProgressIndicator(color: _blue)),
    );
  }

  Widget _buildErrorState(Object error) {
    final message = error is ApiException
        ? error.message
        : 'Gagal memuat daftar aplikasi: $error';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Color(0xFFD66A6A),
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blueGrey.shade700,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _reloadApplications,
            icon: const Icon(Icons.refresh_rounded, size: 17),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 30),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF4FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.apps_outlined, color: _blue, size: 24),
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum ada data aplikasi',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _navy,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Server belum mengirimkan data aplikasi.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blueGrey.shade500,
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
