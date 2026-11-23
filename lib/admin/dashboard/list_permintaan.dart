// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../../services/api_service.dart';

typedef AdminTicketLoader = Future<List<Map<String, dynamic>>> Function({
  required bool isComplaint,
  String? tanggalAwal,
  String? tanggalAkhir,
});

class ListPermintaanPage extends StatefulWidget {
  const ListPermintaanPage({super.key, this.loadTickets});

  final AdminTicketLoader? loadTickets;

  @override
  State<ListPermintaanPage> createState() => _ListPermintaanPageState();
}

class _ListPermintaanPageState extends State<ListPermintaanPage> {
  static const _navy = Color(0xFF17345C);
  static const _blue = Color(0xFF168BFA);
  static const _background = Color(0xFFF4F7FB);

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _requestDate;
  _TicketType _type = _TicketType.complaint;
  _TicketStatus _status = _TicketStatus.open;
  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;
  bool _showServerErrorDetails = false;
  String? _error;
  int _page = 1;
  int _pageSize = 10;
  int _loadGeneration = 0;

  static const _complaintColumns = [
    _TicketColumn('Nomor Tiket', 135, 'ticket'),
    _TicketColumn('Nama Pengusul', 145, 'reporter'),
    _TicketColumn('Ruangan', 140, 'room'),
    _TicketColumn('Permintaan', 140, 'request'),
    _TicketColumn('Kerusakan', 150, 'damage'),
    _TicketColumn('Extension', 90, 'extension'),
    _TicketColumn('Teknisi', 125, 'technician'),
    _TicketColumn('Keterangan', 190, 'description'),
    _TicketColumn('Status', 115, 'status'),
    _TicketColumn('Tanggal dan Waktu Dibuat', 185, 'created'),
    _TicketColumn('#', 64, 'action'),
  ];

  static const _requestColumns = [
    _TicketColumn('Nomor Tiket', 135, 'ticket'),
    _TicketColumn('Nama Pengusul', 145, 'reporter'),
    _TicketColumn('Unit Kerja', 140, 'unit'),
    _TicketColumn('Permintaan', 140, 'request'),
    _TicketColumn('Status', 115, 'status'),
    _TicketColumn('Tanggal dan Waktu Dibuat', 185, 'created'),
    _TicketColumn('#', 64, 'action'),
  ];

  List<_TicketColumn> get _columns =>
      _type == _TicketType.request ? _requestColumns : _complaintColumns;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final generation = ++_loadGeneration;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final start = _type == _TicketType.request
          ? (_requestDate == null ? null : _apiDate(_requestDate!))
          : (_startDate == null ? null : _apiDate(_startDate!));
      final end = _type == _TicketType.request
          ? start
          : (_endDate == null ? null : _apiDate(_endDate!));
      final tickets = widget.loadTickets == null
          ? await _loadFromApi(start, end)
          : await widget.loadTickets!(
              isComplaint: _type == _TicketType.complaint,
              tanggalAwal: start,
              tanggalAkhir: end,
            );
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _tickets = tickets;
        _showServerErrorDetails = false;
        _page = 1;
      });
    } on ApiException catch (error) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() => _error = error.message);
    } catch (error) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() => _error = 'Gagal memuat daftar tiket: $error');
    } finally {
      if (mounted && generation == _loadGeneration) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<List<Map<String, dynamic>>> _loadFromApi(
    String? start,
    String? end,
  ) async {
    if (_type == _TicketType.complaint) {
      final result = await ApiService.instance.getKomplainList(
        tanggalAwal: start,
        tanggalAkhir: end,
        page: 1,
        perPage: 50,
      );
      return result.items.map((item) => item.raw).toList();
    }

    final result = await ApiService.instance.getPermintaanList(
      tanggalAwal: start,
      tanggalAkhir: end,
      page: 1,
      perPage: 50,
    );
    return result.items;
  }

  List<Map<String, dynamic>> get _filteredTickets {
    return _tickets.where((ticket) => _matchesStatus(ticket, _status)).toList();
  }

  List<Map<String, dynamic>> get _visibleTickets {
    final tickets = _filteredTickets;
    final start = (_page - 1) * _pageSize;
    if (start >= tickets.length) return const [];
    final end = (start + _pageSize).clamp(0, tickets.length);
    return tickets.sublist(start, end);
  }

  int get _pageCount =>
      (_filteredTickets.length / _pageSize).ceil().clamp(1, 1000000);

  bool _matchesStatus(
    Map<String, dynamic> ticket,
    _TicketStatus selectedStatus,
  ) {
    final status = _read(ticket, [
      'status',
      'status_name',
      'nama_status',
    ]).toLowerCase();
    final isOpen =
        status.contains('open') ||
        status.contains('baru') ||
        status.contains('buat') ||
        status.contains('pending') ||
        status.contains('menunggu');
    final isInProgress =
        status.contains('proses') ||
        status.contains('diproses') ||
        status.contains('progress');

    switch (selectedStatus) {
      case _TicketStatus.open:
        return isOpen;
      case _TicketStatus.inProgress:
        return isInProgress;
      case _TicketStatus.history:
        return !isOpen && !isInProgress;
    }
  }

  int _countFor(_TicketStatus status) =>
      _tickets.where((ticket) => _matchesStatus(ticket, status)).length;

  String _read(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is Map) {
        final nested = value['name'] ?? value['nama'] ?? value['label'];
        if (nested != null && nested.toString().isNotEmpty) {
          return nested.toString();
        }
      } else if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return '-';
  }

  String _cellValue(Map<String, dynamic> ticket, String key) {
    switch (key) {
      case 'ticket':
        return _read(ticket, ['ticket_no', 'no_tiket', 'ticketNo']);
      case 'reporter':
        return _read(ticket, [
          'pic_internal',
          'pic_eksternal',
          'pic',
          'nama_pengusul',
          'nama',
        ]);
      case 'room':
        return _read(ticket, [
          'unit_kerja_internal',
          'lokasi_external',
          'unit_kerja',
          'ruangan',
        ]);
      case 'unit':
        return _read(ticket, [
          'unit_kerja',
          'unit_kerja_internal',
          'unit_kerja_lainnya',
          'unit',
        ]);
      case 'request':
        return _read(ticket, ['permintaan', 'kategori']);
      case 'damage':
        return _read(ticket, ['kerusakan', 'judul_kerusakan']);
      case 'extension':
        return _read(ticket, ['extension', 'ext']);
      case 'technician':
        return _read(ticket, ['teknisi', 'nama_teknisi']);
      case 'description':
        return _read(ticket, ['keterangan', 'deskripsi']);
      case 'status':
        return _read(ticket, ['status', 'status_name', 'nama_status']);
      case 'created':
        final value = _read(ticket, [
          'created_at',
          'tanggal_dibuat',
          'tanggal',
        ]);
        return _formatDateTime(value);
      default:
        return '-';
    }
  }

  String _formatDateTime(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} $hour:$minute';
  }

  String _apiDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  String _displayDate(DateTime? date) {
    if (date == null) return 'Pilih tanggal';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
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
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      } else {
        _endDate = picked;
        if (_startDate != null && _startDate!.isAfter(picked)) {
          _startDate = picked;
        }
      }
    });
  }

  void _selectType(_TicketType type) {
    if (_type == type) return;
    setState(() => _type = type);
    _loadTickets();
  }

  void _selectStatus(_TicketStatus status) {
    setState(() {
      _status = status;
      _page = 1;
    });
  }

  void _showDetails(Map<String, dynamic> ticket) {
    final details = [
      ('Nomor Tiket', _cellValue(ticket, 'ticket')),
      ('Nama Pengusul', _cellValue(ticket, 'reporter')),
      _type == _TicketType.request
          ? ('Unit Kerja', _cellValue(ticket, 'unit'))
          : ('Ruangan', _cellValue(ticket, 'room')),
      ('Permintaan', _cellValue(ticket, 'request')),
      ('Kerusakan', _cellValue(ticket, 'damage')),
      ('Extension', _cellValue(ticket, 'extension')),
      ('Teknisi', _cellValue(ticket, 'technician')),
      ('Keterangan', _cellValue(ticket, 'description')),
      ('Status', _cellValue(ticket, 'status')),
      ('Tanggal dan Waktu Dibuat', _cellValue(ticket, 'created')),
    ];

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _cellValue(ticket, 'ticket'),
          style: const TextStyle(
            color: _navy,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: details
                  .map(
                    (detail) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 130,
                            child: Text(
                              detail.$1,
                              style: TextStyle(
                                color: Colors.blueGrey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Text(':  '),
                          Expanded(
                            child: Text(
                              detail.$2,
                              style: const TextStyle(
                                color: _navy,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTickets;
    final startIndex = filtered.isEmpty ? 0 : (_page - 1) * _pageSize + 1;
    final endIndex = (_page * _pageSize).clamp(0, filtered.length);

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'List Permintaan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _loadTickets,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: _blue,
          onRefresh: _loadTickets,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              _buildIntroCard(),
              const SizedBox(height: 18),
              _buildTypeSelector(),
              const SizedBox(height: 16),
              _buildDateFilter(),
              const SizedBox(height: 18),
              _buildStatusSelector(),
              const SizedBox(height: 12),
              _buildTableCard(),
              const SizedBox(height: 12),
              _buildPagination(startIndex, endIndex, filtered.length),
              const SizedBox(height: 18),
              Text(
                'RSAB Harapan Kita · Layanan dan Monitoring IT',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 11),
              ),
            ],
          ),
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
            color: _navy.withValues(alpha: 0.13),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MONITORING TIKET',
                  style: TextStyle(
                    color: Color(0xFFCDE6FF),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Kelola permintaan\nlayanan IT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.confirmation_number_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return SegmentedButton<_TicketType>(
      segments: const [
        ButtonSegment(
          value: _TicketType.complaint,
          label: Text('Komplain'),
          icon: Icon(Icons.report_problem_outlined),
        ),
        ButtonSegment(
          value: _TicketType.request,
          label: Text('Permintaan'),
          icon: Icon(Icons.assignment_outlined),
        ),
      ],
      selected: {_type},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => _selectType(selection.first),
      style: SegmentedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        selectedBackgroundColor: const Color(0xFFE5F2FF),
        selectedForegroundColor: _blue,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        side: const BorderSide(color: Color(0xFFDCE5EF)),
      ),
    );
  }

  Widget _buildDateFilter() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE8EDF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_type == _TicketType.complaint) ...[
            const Text(
              'Filter tanggal',
              style: TextStyle(
                color: _navy,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _dateButton(
                    label: 'Tanggal Awal',
                    date: _startDate,
                    onPressed: () => _pickDate(isStart: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _dateButton(
                    label: 'Tanggal Akhir',
                    date: _endDate,
                    onPressed: () => _pickDate(isStart: false),
                  ),
                ),
              ],
            ),
          ] else
            _dateButton(
              label: 'Tanggal',
              date: _requestDate,
              onPressed: _pickRequestDate,
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loadTickets,
              icon: const Icon(Icons.search_rounded, size: 18),
              label: const Text('Cari'),
              style: FilledButton.styleFrom(
                backgroundColor: _blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.blueGrey.shade600,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: _navy,
            backgroundColor: const Color(0xFFFAFCFF),
            side: const BorderSide(color: Color(0xFFDCE5EF)),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  _displayDate(date),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickRequestDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _requestDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
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
    setState(() => _requestDate = picked);
  }

  Widget _buildStatusSelector() {
    const statuses = _TicketStatus.values;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((status) {
          final selected = _status == status;
          final count = _countFor(status);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: selected,
              onSelected: (_) => _selectStatus(status),
              selectedColor: const Color(0xFFE5F2FF),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected
                    ? _blue.withValues(alpha: 0.35)
                    : const Color(0xFFE5EAF1),
              ),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(status.label),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? _blue : const Color(0xFFF0F3F7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: selected ? Colors.white : _navy,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              labelStyle: TextStyle(
                color: selected ? _blue : _navy,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTableCard() {
    final width = _columns.fold<double>(
      0,
      (total, column) => total + column.width,
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE8EDF4)),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 14, 15, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _type == _TicketType.request
                        ? 'Daftar Permintaan'
                        : 'Daftar Komplain',
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(
                  Icons.swipe_rounded,
                  size: 16,
                  color: Colors.blueGrey.shade400,
                ),
                const SizedBox(width: 5),
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
              width: width,
              child: Column(
                children: [
                  _buildTableHeader(),
                  if (!_isLoading && _error == null)
                    ..._visibleTickets.map(_buildTableRow),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(36),
              child: Center(child: CircularProgressIndicator(color: _blue)),
            )
          else if (_error != null)
            _buildErrorState()
          else if (_visibleTickets.isEmpty)
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(bottom: BorderSide(color: Color(0xFFE9EEF5))),
      ),
      child: Row(
        children: _columns
            .map(
              (column) => SizedBox(
                width: column.width,
                child: Text(
                  column.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF52647A),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> ticket) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F3F7))),
      ),
      child: Row(
        children: _columns.map((column) {
          if (column.key == 'action') {
            return SizedBox(
              width: column.width,
              child: IconButton(
                tooltip: 'Lihat detail',
                onPressed: () => _showDetails(ticket),
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: _blue,
                  size: 19,
                ),
              ),
            );
          }
          if (column.key == 'status') {
            final value = _cellValue(ticket, column.key);
            return SizedBox(
              width: column.width,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(value).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: _statusColor(value),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          }
          final value = _cellValue(ticket, column.key);
          return SizedBox(
            width: column.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9),
              child: Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: column.key == 'ticket'
                    ? TextAlign.left
                    : TextAlign.center,
                style: TextStyle(
                  color: column.key == 'ticket' ? _blue : _navy,
                  fontSize: 11,
                  fontWeight: column.key == 'ticket'
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _statusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('selesai') || normalized.contains('tutup')) {
      return const Color(0xFF159A66);
    }
    if (normalized.contains('proses')) return _blue;
    if (normalized.contains('pending') || normalized.contains('menunggu')) {
      return const Color(0xFFCE8511);
    }
    if (normalized.contains('batal') || normalized.contains('tolak')) {
      return const Color(0xFFD64A4A);
    }
    return const Color(0xFF63758A);
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 34, color: Colors.blueGrey.shade300),
          const SizedBox(height: 8),
          Text(
            'Tidak ada data ${_type.label.toLowerCase()} yang sesuai.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final message = _error!;
    final normalizedMessage = message.toLowerCase();
    final endpointUnavailable =
        _type == _TicketType.request &&
        (normalizedMessage.contains('method not allowed') ||
            normalizedMessage.contains('405') ||
            (normalizedMessage.contains('metode') &&
                normalizedMessage.contains('endpoint')));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Color(0xFFD64A4A),
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            endpointUnavailable
                ? 'Endpoint daftar permintaan belum tersedia di server.'
                : message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12),
          ),
          if (endpointUnavailable) ...[
            GestureDetector(
              onTap: () => setState(
                () => _showServerErrorDetails = !_showServerErrorDetails,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Detail error server',
                      style: TextStyle(
                        color: _blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _showServerErrorDetails
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: _blue,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            if (_showServerErrorDetails)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blueGrey.shade500,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _loadTickets,
            icon: const Icon(Icons.refresh_rounded, size: 17),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(int first, int last, int total) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFDCE5EF)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _pageSize,
              isDense: true,
              items: const [10, 25, 50]
                  .map(
                    (size) =>
                        DropdownMenuItem(value: size, child: Text('$size')),
                  )
                  .toList(),
              onChanged: (size) {
                if (size == null) return;
                setState(() {
                  _pageSize = size;
                  _page = 1;
                });
              },
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            total == 0
                ? 'Tidak ada data'
                : 'Menampilkan $first–$last dari $total',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 10),
          ),
        ),
        IconButton(
          tooltip: 'Halaman sebelumnya',
          onPressed: _page > 1 ? () => setState(() => _page--) : null,
          icon: const Icon(Icons.chevron_left_rounded),
          visualDensity: VisualDensity.compact,
        ),
        Text(
          '$_page/$_pageCount',
          style: const TextStyle(
            color: _navy,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        IconButton(
          tooltip: 'Halaman berikutnya',
          onPressed: _page < _pageCount ? () => setState(() => _page++) : null,
          icon: const Icon(Icons.chevron_right_rounded),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

enum _TicketType {
  complaint('Komplain'),
  request('Permintaan');

  const _TicketType(this.label);

  final String label;
}

enum _TicketStatus {
  open('Open'),
  inProgress('Proses'),
  history('Histori');

  const _TicketStatus(this.label);

  final String label;
}

class _TicketColumn {
  const _TicketColumn(this.label, this.width, this.key);

  final String label;
  final double width;
  final String key;
}
