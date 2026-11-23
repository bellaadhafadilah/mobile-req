// ignore: deprecated_member_use
import 'package:flutter/material.dart';

enum _MonitoringTab { delivery, unsentEncounters }

class MonitoringSerenicPage extends StatefulWidget {
  const MonitoringSerenicPage({super.key});

  @override
  State<MonitoringSerenicPage> createState() => _MonitoringSerenicPageState();
}

class _MonitoringSerenicPageState extends State<MonitoringSerenicPage> {
  static const _navy = Color(0xFF17345C);
  static const _blue = Color(0xFF168BFA);
  static const _background = Color(0xFFF4F7FB);

  late DateTime _startDate;
  late DateTime _endDate;
  late DateTime _appliedStartDate;
  late DateTime _appliedEndDate;
  _MonitoringTab _selectedTab = _MonitoringTab.delivery;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _endDate = DateTime(today.year, today.month, today.day);
    _startDate = _endDate.subtract(const Duration(days: 10));
    _appliedStartDate = _startDate;
    _appliedEndDate = _endDate;
  }

  Future<void> _selectDate({required bool isStartDate}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: isStartDate ? 'PILIH TANGGAL AWAL' : 'PILIH TANGGAL AKHIR',
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
      if (isStartDate) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  void _applyDateRange() {
    if (_startDate.isAfter(_endDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal awal tidak boleh melewati tanggal akhir.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _appliedStartDate = _startDate;
      _appliedEndDate = _endDate;
    });
  }

  void _showActionMessage(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action belum terhubung ke layanan Serenic.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDelivery = _selectedTab == _MonitoringTab.delivery;
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 4,
        title: const Text(
          'Monitoring Serenic',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            _buildIntroCard(),
            const SizedBox(height: 18),
            _buildTabs(),
            const SizedBox(height: 16),
            if (!isDelivery) ...[
              _buildEncounterNotice(),
              const SizedBox(height: 14),
            ],
            if (isDelivery) ...[
              _buildDeliveryActions(),
              const SizedBox(height: 16),
            ],
            _buildDateFilter(isDelivery: isDelivery),
            if (!isDelivery) ...[
              const SizedBox(height: 16),
              _buildEncounterSendAction(),
            ],
            const SizedBox(height: 18),
            _buildResults(isDelivery: isDelivery),
            const SizedBox(height: 14),
            Text(
              'Periode ${_formatDate(_appliedStartDate)} - '
              '${_formatDate(_appliedEndDate)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueGrey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF17345C), Color(0xFF246A9A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.monitor_heart_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halaman Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pantau pengiriman data dan status encounter.',
                  style: TextStyle(
                    color: Color(0xFFD8E8F7),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE5EBF2)),
      ),
      child: Row(
        children: [
          _tabButton(
            tab: _MonitoringTab.delivery,
            label: 'Monitoring Pengiriman',
            icon: Icons.sync_alt_rounded,
          ),
          const SizedBox(width: 4),
          _tabButton(
            tab: _MonitoringTab.unsentEncounters,
            label: 'Encounter Belum Terkirim',
            icon: Icons.pending_actions_rounded,
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required _MonitoringTab tab,
    required String label,
    required IconData icon,
  }) {
    final selected = _selectedTab == tab;
    return Expanded(
      child: Material(
        color: selected ? _blue : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: () => setState(() => _selectedTab = tab),
          borderRadius: BorderRadius.circular(11),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Column(
              children: [
                Icon(icon, size: 18, color: selected ? Colors.white : _navy),
                const SizedBox(height: 5),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    color: selected ? Colors.white : _navy,
                    fontSize: 10,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryActions() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aksi Pengiriman',
            style: TextStyle(
              color: _navy,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _actionButton('Kirim prerequisites', Icons.upload_rounded),
              _actionButton('Kirim Encounter', Icons.send_rounded),
              _actionButton(
                'Kirim Completed Encounter',
                Icons.task_alt_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEncounterNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8EAFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: _blue, size: 19),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Data encounter belum dapat diperiksa karena layanan Serenic belum terhubung.',
              style: TextStyle(
                color: _navy,
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () => _showActionMessage(label),
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: _blue,
        backgroundColor: const Color(0xFFF1F8FF),
        side: BorderSide(color: _blue.withValues(alpha: 0.12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDateFilter({required bool isDelivery}) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.date_range_rounded, color: _blue, size: 19),
              SizedBox(width: 8),
              Text(
                'Filter Periode',
                style: TextStyle(
                  color: _navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 390) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _dateField(
                      label: 'Tanggal awal',
                      value: _formatDate(_startDate),
                      onTap: () => _selectDate(isStartDate: true),
                    ),
                    const SizedBox(height: 10),
                    _dateField(
                      label: 'Tanggal akhir',
                      value: _formatDate(_endDate),
                      onTap: () => _selectDate(isStartDate: false),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: _dateField(
                      label: 'Tanggal awal',
                      value: _formatDate(_startDate),
                      onTap: () => _selectDate(isStartDate: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dateField(
                      label: 'Tanggal akhir',
                      value: _formatDate(_endDate),
                      onTap: () => _selectDate(isStartDate: false),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _applyDateRange,
              icon: const Icon(Icons.filter_alt_rounded, size: 18),
              label: Text(isDelivery ? 'Tampilkan' : 'Cek Data'),
              style: FilledButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.blueGrey.shade600,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: const Color(0xFFFAFCFF),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFDCE5EF)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_month_rounded,
                    size: 18,
                    color: _blue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults({required bool isDelivery}) {
    final title = isDelivery
        ? 'Monitoring Pengiriman Serenic'
        : 'Encounter Belum Terkirim';
    final subtitle = isDelivery ? 'Ringkasan status pengiriman data' : '';
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.blueGrey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Belum terhubung',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isDelivery) ...[
            _buildDeliveryTableHeader(),
            const SizedBox(height: 12),
          ] else ...[
            _buildEncounterTableHeader(),
            const SizedBox(height: 12),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 25),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE7EDF4)),
            ),
            child: Column(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF4FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.inbox_rounded,
                    color: _blue,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 11),
                Text(
                  isDelivery
                      ? 'Belum ada data pengiriman'
                      : 'Belum ada encounter tertunda',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Data akan tampil setelah layanan Serenic terhubung.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blueGrey.shade500,
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryTableHeader() {
    const headers = [
      'Nama Service',
      'Tanggal Kirim',
      'Jumlah Data Dikirim',
      'Total Error',
      'Total Unknown',
      'Total Success',
      'Detail',
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7EDF4)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          horizontalMargin: 14,
          columnSpacing: 24,
          headingRowHeight: 48,
          dividerThickness: 0,
          columns: [
            for (final header in headers)
              DataColumn(
                label: Text(
                  header,
                  style: TextStyle(
                    color: Colors.blueGrey.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
          rows: const [],
        ),
      ),
    );
  }

  Widget _buildEncounterSendAction() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: () => _showActionMessage('Kirim Encounter Terpilih'),
            icon: const Icon(Icons.send_rounded, size: 17),
            label: const Text('Kirim Encounter Terpilih'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _blue,
              backgroundColor: const Color(0xFFF1F8FF),
              side: BorderSide(color: _blue.withValues(alpha: 0.12)),
              padding: const EdgeInsets.symmetric(vertical: 13),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.checklist_rounded,
                color: Colors.blueGrey.shade500,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '0 registrasi dipilih',
                style: TextStyle(
                  color: Colors.blueGrey.shade600,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEncounterTableHeader() {
    const headers = [
      'Tanggal Registrasi',
      'No. Registrasi',
      'No. Rekam',
      'Kelompok Pasien',
      'No. SEP',
      'Status',
      'Aksi',
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7EDF4)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          horizontalMargin: 14,
          columnSpacing: 24,
          headingRowHeight: 48,
          dividerThickness: 0,
          columns: [
            const DataColumn(label: Checkbox(value: false, onChanged: null)),
            for (final header in headers)
              DataColumn(
                label: Text(
                  header,
                  style: TextStyle(
                    color: Colors.blueGrey.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
          rows: const [],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EDF3)),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
