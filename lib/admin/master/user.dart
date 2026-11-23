// ignore: deprecated_member_use
import 'package:flutter/material.dart';

class AdminUserPage extends StatefulWidget {
  const AdminUserPage({super.key});

  @override
  State<AdminUserPage> createState() => _AdminUserPageState();
}

class _AdminUserPageState extends State<AdminUserPage> {
  static const _navy = Color(0xFF17345C);
  static const _blue = Color(0xFF168BFA);
  static const _teal = Color(0xFF159A91);
  static const _background = Color(0xFFF4F7FB);

  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _unitController = TextEditingController();
  final List<_AdminUser> _users = [];
  String _query = '';

  List<_AdminUser> get _filteredUsers {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _users;
    return _users.where((user) {
      return user.name.toLowerCase().contains(query) ||
          user.username.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.unit.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _showAddUserDialog() async {
    final formKey = GlobalKey<FormState>();
    _nameController.clear();
    _usernameController.clear();
    _emailController.clear();
    _unitController.clear();

    final user = await showDialog<_AdminUser>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
        contentPadding: const EdgeInsets.fromLTRB(22, 10, 22, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        title: const Text(
          'Tambah User',
          style: TextStyle(
            color: _navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: SizedBox(
          width: 380,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _formField(
                    controller: _nameController,
                    label: 'Nama',
                    hint: 'Nama lengkap',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 13),
                  _formField(
                    controller: _usernameController,
                    label: 'Username',
                    hint: 'Username untuk login',
                    icon: Icons.alternate_email_rounded,
                    validator: (value) {
                      final error = _required(value, 'Username');
                      if (error != null) return error;
                      final exists = _users.any(
                        (user) =>
                            user.username.toLowerCase() ==
                            value!.trim().toLowerCase(),
                      );
                      return exists ? 'Username sudah digunakan' : null;
                    },
                  ),
                  const SizedBox(height: 13),
                  _formField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'nama@rumahsakit.go.id',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final error = _required(value, 'Email');
                      if (error != null) return error;
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(value!.trim())) {
                        return 'Format email belum benar';
                      }
                      final exists = _users.any(
                        (user) =>
                            user.email.toLowerCase() ==
                            value.trim().toLowerCase(),
                      );
                      return exists ? 'Email sudah digunakan' : null;
                    },
                  ),
                  const SizedBox(height: 13),
                  _formField(
                    controller: _unitController,
                    label: 'Unit kerja',
                    hint: 'Nama unit kerja',
                    icon: Icons.business_outlined,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(
                dialogContext,
                _AdminUser(
                  name: _nameController.text.trim(),
                  username: _usernameController.text.trim(),
                  email: _emailController.text.trim(),
                  unit: _unitController.text.trim(),
                ),
              );
            },
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 17),
            label: const Text('Simpan'),
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

    if (user == null || !mounted) return;
    setState(() => _users.add(user));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User ditambahkan untuk sesi halaman ini.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label wajib diisi';
    return null;
  }

  Widget _formField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization:
          label == 'Username' || keyboardType == TextInputType.emailAddress
          ? TextCapitalization.none
          : TextCapitalization.words,
      validator: validator ?? (value) => _required(value, label),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 19, color: _blue),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDCE5EF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDCE5EF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _blue, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'List User',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const ValueKey('user-search'),
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'Cari nama, username, email...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: _blue,
                      ),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Hapus pencarian',
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: const BorderSide(color: Color(0xFFE2E9F1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: const BorderSide(color: Color(0xFFE2E9F1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: const BorderSide(color: _blue, width: 1.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: _showAddUserDialog,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Tambah'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildUserTable(users),
            const SizedBox(height: 18),
            Text(
              'Created by Instalasi SIMRS RSAB Harapan Kita',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        gradient: const LinearGradient(
          colors: [_navy, Color(0xFF24649C)],
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
                  'Kelola akun pengguna',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Tambah dan temukan user berdasarkan unit kerja.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.manage_accounts_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTable(List<_AdminUser> users) {
    const columns = [
      ('Nama', 180.0),
      ('Username', 145.0),
      ('email', 220.0),
      ('Unit kerja', 190.0),
    ];
    const tableWidth = 735.0;

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
                    Icons.people_alt_rounded,
                    color: _blue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daftar Pengguna',
                        style: TextStyle(
                          color: _navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${users.length} user',
                        style: TextStyle(
                          color: Colors.blueGrey.shade500,
                          fontSize: 10,
                        ),
                      ),
                    ],
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
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE8EDF3)),
                      ),
                    ),
                    child: Row(
                      children: columns
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
                  ),
                  ...users.map(_buildUserRow),
                ],
              ),
            ),
          ),
          if (users.isEmpty)
            _buildEmptyState(
              _query.isEmpty
                  ? 'Belum ada user. Tambahkan user pertama untuk memulai.'
                  : 'Tidak ada user yang cocok dengan pencarian.',
            ),
        ],
      ),
    );
  }

  Widget _buildUserRow(_AdminUser user) {
    final initials = user.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F3F7))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFEAF4FF),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: _blue,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _userCell(user.username, 145),
          _userCell(user.email, 220),
          SizedBox(
            width: 190,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F7F4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.unit,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _teal,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userCell(String value, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blueGrey.shade700, fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _query.isEmpty
                  ? Icons.person_add_alt_1_rounded
                  : Icons.search_off_rounded,
              color: Colors.blueGrey.shade400,
              size: 23,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blueGrey.shade500,
              fontSize: 11,
              height: 1.45,
            ),
          ),
          if (_query.isEmpty) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _showAddUserDialog,
              icon: const Icon(Icons.add_rounded, size: 17),
              label: const Text('Tambah user'),
            ),
          ],
        ],
      ),
    );
  }
}

class _AdminUser {
  const _AdminUser({
    required this.name,
    required this.username,
    required this.email,
    required this.unit,
  });

  final String name;
  final String username;
  final String email;
  final String unit;
}
