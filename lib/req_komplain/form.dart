import 'dart:math';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class KomplainFormPage extends StatefulWidget {
  const KomplainFormPage({super.key});

  @override
  State<KomplainFormPage> createState() => _KomplainFormPageState();
}

class _KomplainFormPageState extends State<KomplainFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController noTeleponController = TextEditingController();
  final TextEditingController extensionController = TextEditingController();
  final TextEditingController judulKerusakanController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();
  final TextEditingController captchaController = TextEditingController();

  String selectedJenisPelapor = 'Internal';
  String? selectedKategori;
  bool _isLoading = false;        // ← tambahan: state loading saat submit
  late String currentCaptcha;

  final List<Map<String, dynamic>> daftarKategori = [
    {
      'name': 'Hardware',
      'icon': Icons.desktop_windows_outlined,
      'color': Color(0xFF0284C7),
    },
    {
      'name': 'Jaringan',
      'icon': Icons.language_outlined,
      'color': Color(0xFF0D9488),
    },
    {
      'name': 'Software',
      'icon': Icons.laptop_chromebook_outlined,
      'color': Color(0xFF6366F1),
    },
    {
      'name': 'Sistem Aplikasi',
      'icon': Icons.folder_open_outlined,
      'color': Color(0xFFD97706),
    },
  ];

  @override
  void initState() {
    super.initState();
    generateCaptcha();
  }

  void generateCaptcha() {
    final random = Random();
    final code = (1000 + random.nextInt(9000)).toString();
    setState(() {
      currentCaptcha = code;
    });
  }

  @override
  void dispose() {
    noTeleponController.dispose();
    extensionController.dispose();
    judulKerusakanController.dispose();
    keteranganController.dispose();
    captchaController.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    if (selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih kategori komplain terlebih dahulu'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (captchaController.text.trim() != currentCaptcha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode captcha tidak sesuai, silakan coba lagi'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      generateCaptcha();
      captchaController.clear();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final TicketResult result;

      if (selectedJenisPelapor == 'Internal') {
        result = await ApiService.instance.submitKomplainInternal(
          unitKerjaInternal: extensionController.text.trim(), // extension dipakai sbg unit/lokasi internal
          picInternal: noTeleponController.text.trim(),       // disesuaikan dengan field form yang ada
          permintaan: selectedKategori!,
          noTelepon: noTeleponController.text.trim(),
          kerusakan: judulKerusakanController.text.trim(),
          keterangan: keteranganController.text.trim(),
        );
      } else {
        result = await ApiService.instance.submitKomplainEksternal(
          lokasiExternal: extensionController.text.trim(),
          picEksternal: noTeleponController.text.trim(),
          permintaan: selectedKategori!,
          noTelepon: noTeleponController.text.trim(),
          kerusakan: judulKerusakanController.text.trim(),
          keterangan: keteranganController.text.trim(),
        );
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Berhasil', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Komplain IT Anda telah berhasil dikirimkan.'),
              const SizedBox(height: 10),
              Text(
                'No. Tiket: ${result.ticketNo}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0090FF),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Simpan nomor tiket untuk cek status komplain.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0090FF),
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      String pesanError = e.message;
      if (e.statusCode == 422 && e.fieldErrors.isNotEmpty) {
        pesanError = e.fieldErrors.entries
            .map((entry) => '${entry.key}: ${entry.value.join(', ')}')
            .join('\n');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pesanError),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      generateCaptcha();
      captchaController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal terhubung ke server: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              // Card Utama Form Komplain IT
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Form
                      const Text(
                        'Form Komplain IT',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 1. Jenis Pelapor
                      buildLabel('Jenis Pelapor'),
                      Row(
                        children: [
                          buildRadioOption('Internal'),
                          const SizedBox(width: 20),
                          buildRadioOption('External'),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 2. Kategori Komplain
                      buildLabel('Kategori Komplain'),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.3,
                        ),
                        itemCount: daftarKategori.length,
                        itemBuilder: (context, index) {
                          final item = daftarKategori[index];
                          final isSelected = selectedKategori == item['name'];

                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedKategori = item['name'];
                              });
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFF0F9FF) : Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF0090FF) : const Color(0xFFE2E8F0),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: item['name'],
                                    groupValue: selectedKategori,
                                    activeColor: const Color(0xFF0090FF),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    onChanged: (val) {
                                      setState(() {
                                        selectedKategori = val;
                                      });
                                    },
                                  ),
                                  Icon(
                                    item['icon'],
                                    size: 18,
                                    color: item['color'],
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      item['name'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: const Color(0xFF1E293B),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // 3. No Telepon
                      buildLabel('No Telepon'),
                      TextFormField(
                        controller: noTeleponController,
                        keyboardType: TextInputType.phone,
                        decoration: inputDecoration('Masukkan no HP'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nomor telepon wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info, color: Color(0xFFE11D48), size: 14),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Nomor telepon akan digunakan sebagai verifikasi pembatalan komplain dengan memasukkan 4 digit terakhir.',
                              style: TextStyle(
                                color: Color(0xFFE11D48),
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 4. Extension
                      buildLabel('Extension'),
                      TextFormField(
                        controller: extensionController,
                        keyboardType: TextInputType.number,
                        decoration: inputDecoration('masukan extension'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Extension wajib diisi';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // 5. Judul kerusakan
                      buildLabel('Judul kerusakan'),
                      TextFormField(
                        controller: judulKerusakanController,
                        decoration: inputDecoration('masukan judul kerusakan'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Judul kerusakan wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Contoh: Komputer, Printer, Jaringan internet, Monitor, dan lain-lain.',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 6. Keterangan
                      buildLabel('Keterangan'),
                      TextFormField(
                        controller: keteranganController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: inputDecoration('Masukkan Keterangan'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Keterangan wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Contoh: Komputer tidak dapat menyala, Printer tidak bisa mencetak, Jaringan internet lambat, Monitor berkedip, dan lain-lain.',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 7. Captcha
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  currentCaptcha.split('').join(' '),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF1E293B),
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: generateCaptcha,
                                  child: const Icon(
                                    Icons.refresh,
                                    size: 18,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: captchaController,
                              keyboardType: TextInputType.number,
                              decoration: inputDecoration('Masukkan captcha'),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Wajib diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 8. Tombol Submit & Kembali
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _isLoading ? null : submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0090FF),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: _isLoading
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE94E77),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              'Kembali',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Radio Jenis Pelapor
  Widget buildRadioOption(String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: value,
          groupValue: selectedJenisPelapor,
          activeColor: const Color(0xFF0090FF),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: (val) {
            if (val != null) {
              setState(() {
                selectedJenisPelapor = val;
              });
            }
          },
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Widget Label Field dengan Tanda Bintang Merah (*)
  Widget buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF1E293B),
          ),
          children: const [
            TextSpan(
              text: ' *',
              style: TextStyle(
                color: Color(0xFFE11D48),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Input Decoration Standard
  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 13,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}
