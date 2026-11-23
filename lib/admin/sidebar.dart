// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../auth/login.dart';
import '../dashboard_req/index.dart';
import 'dashboard/monitoring_serenic.dart';
import 'dashboard/list_permintaan.dart';
import 'master/aplikasi_simrs.dart';
import 'master/user.dart';

class AdminSidebar extends StatefulWidget {
  const AdminSidebar({super.key});

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  static const _navy = Color(0xFF17345C);
  static const _blue = Color(0xFF168BFA);
  static const _teal = Color(0xFF159A91);
  static const _muted = Color(0xFF718096);

  bool _dashboardExpanded = true;
  bool _masterExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _sectionLabel('MENU UTAMA'),
                  _menuGroup(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        splashColor: _blue.withValues(alpha: 0.06),
                        highlightColor: _blue.withValues(alpha: 0.03),
                      ),
                      child: ExpansionTile(
                        initiallyExpanded: _dashboardExpanded,
                        onExpansionChanged: (expanded) {
                          setState(() => _dashboardExpanded = expanded);
                        },
                        tilePadding: const EdgeInsets.symmetric(horizontal: 10),
                        childrenPadding: const EdgeInsets.only(
                          left: 18,
                          right: 4,
                          bottom: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        leading: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF4FF),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.dashboard_rounded,
                            color: _blue,
                            size: 19,
                          ),
                        ),
                        title: const Text(
                          'Dashboard',
                          style: TextStyle(
                            color: _navy,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        trailing: AnimatedRotation(
                          turns: _dashboardExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.blueGrey.shade400,
                            size: 22,
                          ),
                        ),
                        children: [
                          _submenuItem(
                            title: 'Dashboard Komplain',
                            icon: Icons.space_dashboard_rounded,
                            selected: true,
                            onTap: () => Navigator.pop(context),
                          ),
                          _submenuItem(
                            title: 'List Permintaan',
                            icon: Icons.assignment_outlined,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ListPermintaanPage(),
                                ),
                              );
                            },
                          ),
                          _submenuItem(
                            title: 'Monitoring Smart',
                            icon: Icons.monitor_heart_outlined,
                            onTap: () => _showUnavailableMenu(
                              context,
                              'Monitoring Smart',
                            ),
                          ),
                          _submenuItem(
                            title: 'Monitoring Serenic',
                            icon: Icons.monitor_heart_rounded,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MonitoringSerenicPage(),
                                ),
                              );
                            },
                          ),
                          _submenuItem(
                            title: 'Laporan Komplain',
                            icon: Icons.description_outlined,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DashboardReqPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _sectionLabel('PENGELOLAAN'),
                  _menuGroup(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        splashColor: _teal.withValues(alpha: 0.06),
                        highlightColor: _teal.withValues(alpha: 0.03),
                      ),
                      child: ExpansionTile(
                        initiallyExpanded: _masterExpanded,
                        onExpansionChanged: (expanded) {
                          setState(() => _masterExpanded = expanded);
                        },
                        tilePadding: const EdgeInsets.symmetric(horizontal: 10),
                        childrenPadding: const EdgeInsets.only(
                          left: 18,
                          right: 4,
                          bottom: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        leading: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F7F5),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.folder_special_rounded,
                            color: _teal,
                            size: 19,
                          ),
                        ),
                        title: const Text(
                          'Master',
                          style: TextStyle(
                            color: _navy,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        trailing: AnimatedRotation(
                          turns: _masterExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.blueGrey.shade400,
                            size: 22,
                          ),
                        ),
                        children: [
                          _submenuItem(
                            title: 'User',
                            icon: Icons.people_outline_rounded,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminUserPage(),
                                ),
                              );
                            },
                          ),
                          _submenuItem(
                            title: 'Aplikasi SIMRS',
                            icon: Icons.apps_rounded,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AplikasiSimrsPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _drawerItem(
              context,
              icon: Icons.logout_rounded,
              title: 'Keluar',
              danger: true,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 19),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF142D4F), Color(0xFF205B83)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -55,
            right: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.055),
              ),
            ),
          ),
          Positioned(
            right: 42,
            bottom: -48,
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _teal.withValues(alpha: 0.18),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/icons/logo-fullname.png',
                  height: 37,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_hospital_rounded, color: _teal),
                      SizedBox(width: 8),
                      Text(
                        'RSAB Harapan Kita',
                        style: TextStyle(
                          color: _navy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 49,
                    height: 49,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 29,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Administrator',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Layanan IT RSAB Harapan Kita',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.76),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF63D6A4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'PANEL ADMIN',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 9, 12, 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider(height: 1, color: Color(0xFFE8EDF3))),
        ],
      ),
    );
  }

  Widget _menuGroup({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE9EEF4)),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _submenuItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: selected ? const Color(0xFFEAF4FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: selected ? _blue : Colors.blueGrey.shade400,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: selected ? _blue : _navy,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (selected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: _blue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
    bool danger = false,
  }) {
    final itemColor = danger
        ? const Color(0xFFD64A4A)
        : selected
        ? _blue
        : _navy;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: ListTile(
        onTap: onTap,
        selected: selected,
        selectedTileColor: const Color(0xFFEAF4FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: danger ? const Color(0xFFFFF5F5) : null,
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: danger ? const Color(0xFFFFE7E7) : const Color(0xFFF0F4F8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: danger ? itemColor : Colors.blueGrey.shade500,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: itemColor,
            fontSize: 13,
            fontWeight: selected || danger ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showUnavailableMenu(BuildContext context, String title) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title belum tersedia.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
