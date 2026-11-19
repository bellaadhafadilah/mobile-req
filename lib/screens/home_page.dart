
import 'package:flutter/material.dart';
import '../req_permintaan/form.dart';
import '../cek_status/form.dart';
import '../req_komplain/form.dart';
import '../dashboard_req/index.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildCard(
              icon: Icons.add_box_rounded,
              title: 'Request Permintaan Baru',
              subtitle: 'Buat dan ajukan permintaan layanan IT baru',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RequestFormPage(),
                  ),
                );
              },
            ),

            buildCard(
              icon: Icons.pending_actions_rounded,
              title: 'Cek Status Permintaan',
              subtitle: 'Pantau status dan progres permintaan IT',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CekStatusPage(),
                  ),
                );
              },
            ),

            buildCard(
              icon: Icons.build_circle_rounded,
              title: 'Permintaan Komplain Hardware',
              subtitle: 'Laporkan kendala atau kerusakan perangkat hardware',
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KomplainFormPage(),
                  ),
                );
              },
            ),

            buildCard(
              icon: Icons.dashboard_rounded,
              title: 'Dashboard Permintaan',
              subtitle: 'Lihat ringkasan dan statistik seluruh permintaan IT',
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardReqPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
          ),
        ),
      ),
    );
  }
}
