import 'dart:math';

// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';

class RequestFormPage extends StatefulWidget {
  const RequestFormPage({super.key});

  @override
  State<RequestFormPage> createState() => _RequestFormPageState();
}

class _RequestFormPageState extends State<RequestFormPage> {
  static const _navy = Color(0xFF17345C);
  static const _blue = Color(0xFF2868C7);
  static const _teal = Color(0xFF159A91);
  static const _pageBackground = Color(0xFFF4F7FB);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();
  final TextEditingController unitLainnyaController = TextEditingController();
  final TextEditingController unitDisplayController = TextEditingController();
  final TextEditingController captchaController = TextEditingController();

  String? selectedUnit;
  String? selectedPermintaan;
  String? teleponError;
  late String currentCaptcha;

  List<PlatformFile> selectedFiles = [];
  bool _isLoading = false; // ← tambahan: state loading saat submit
  List<String>? _apiUnits;
  List<String>? _apiPermintaan;

  final List<String> daftarUnit = [
    'Instalasi Farmasi',
    'Instalasi Laboratorium Terpadu',
    'Instalasi Gizi',
    'Instalasi Pelatihan',
    'Komite Medik',
    'Penerimaan Hasil Pekerjaan',
    'Pejabat Pengadaan',
    'Instalasi Sistem Informasi Manajemen Rumah Sakit',
    'Komite Mutu',
    'Instalasi Verifikasi dan Penjaminan Pasien',
    'Tim Kerja Pendidikan dan Pelatihan',
    'Instalasi Bedah Sentral',
    'Instalasi Perinatal Terpadu',
    'Instalasi Rekam Medik',
    'Unit Layanan Pengadaan Barang/Jasa',
    'Instalasi Sterilisasi Sentral dan Binatu',
    'Tim Kerja Akuntansi dan BMN',
    'Tim Kerja Organisasi dan SDM',
    'Tim Kerja Perencanaan dan Evaluasi Program',
    'Tim Kerja Tata Usaha dan Rumah Tangga',
    'Instalasi Rehabilitasi Medik',
    'Departemen Pediatri',
    'Kelompok Staf Medik Gigi dan Mulut',
    'Departemen Obstetri dan Ginekologi',
    'Departemen Bedah',
    'Komite Keperawatan dan Tenaga Kesehatan Lain',
    'Departemen Medik',
    'Komite Etik dan Hukum',
    'Instalasi Hubungan Masyarakat dan Bina Pelanggan',
    'Tim Kerja Hukum dan Hubungan Masyarakat',
    'Tim Kerja Pelayanan Penunjang',
    'Tim Kerja Pelayanan Keperawatan',
    'Tim Kerja Pelayanan Medik',
    'Komite Pencegahan, Pengendalian Infeksi dan Pengendalian Resistensi Antimikroba',
    'Tim Kerja Pelaksanaan Keuangan',
    'Instalasi Penelitian Pusat Inisiatif Sekuensing Genom dan Biomedis',
    'Instalasi Pengembangan Jejaring Nasional dan Internasional',
    'Direksi',
    'Pejabat Pembuat Komitmen',
    'Farmasi Klinik Utama',
    'Tim Kerja Perencanaan dan Evaluasi Anggaran',
    'Instalasi Rawat Jalan Eksekutif Amarylis',
    'Instalasi Pemeliharaan Sarana Prasarana Rumah Sakit',
    'Komite Tenaga Kesehatan Lain',
    'Instalasi Kesehatan Lingkungan dan Keselamatan dan Kesehatan Kerja Rumah Sakit',
    'Instalasi Pemasaran dan Pengembangan Bisnis',
    'Instalasi Pengadaan Barang/Jasa',
    'Satuan Pemeriksaan Internal',
    'Instalasi Teknologi Reproduksi Berbantu',
    'Kelompok Staf Medik Umum',
    'Kelompok Staf Medik Anestesiologi dan Terapi Intensif',
    'Unit Pelayanan Kesehatan Klinik Utama',
    'Instalasi Gawat Darurat',
    'Instalasi Rawat Intensif',
    'Instalasi Rawat Jalan Eksekutif',
    'Instalasi Rawat Jalan Reguler',
    'Instalasi Radiologi',
    'Instalasi Klinik Utama',
    'Instalasi Rawat Inap',
    'Instalasi Rehabilitasi Medik Eksekutif',
    'Komite Etik Penelitian Kesehatan',
    'Clinical Research Unit (CRU)',
    'Unit Fungsional Pendidikan',
    'Komite Farmasi dan Terapi, PPI, dan PPRA',
    'Lainnya',
  ];

  final List<String> daftarPermintaan = [
    'Pembuatan Aplikasi Baru',
    'Pengembangan Aplikasi',
    'Permintaan Data',
  ];

  List<String> get _availablePermintaan {
    final apiOptions = _apiPermintaan
        ?.where((option) => option.trim().isNotEmpty)
        .toList();
    return apiOptions == null || apiOptions.isEmpty
        ? daftarPermintaan
        : apiOptions;
  }

  @override
  void initState() {
    super.initState();
    generateCaptcha();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final options = await ApiService.instance.getOptions();
      if (!mounted) return;
      setState(() {
        _apiUnits = options.units;
        _apiPermintaan = options.tipes;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilihan form tidak dapat dimuat: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat pilihan form dari server: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void generateCaptcha() {
    final random = Random();
    final code = (1000 + random.nextInt(9000)).toString();
    setState(() {
      currentCaptcha = code;
    });
  }

  // PILIH FILE
  Future<void> pilihFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
      );

      if (result != null) {
        setState(() {
          selectedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal memilih file: $e')));
    }
  }

  // HAPUS FILE
  void hapusFile(int index) {
    setState(() {
      selectedFiles.removeAt(index);
    });
  }

  // SUBMIT FORM — terhubung ke API backend
  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedPermintaan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih jenis permintaan')),
      );
      return;
    }

    if (selectedUnit == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Silakan pilih unit kerja')));
      return;
    }

    if (selectedUnit == 'Lainnya' &&
        unitLainnyaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan isi nama unit kerja')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final TicketResult result;

      if (selectedFiles.isNotEmpty) {
        // Kirim dengan lampiran file (multipart)
        result = await ApiService.instance.submitPermintaanWithFiles(
          unitKerja: selectedUnit!,
          unitKerjaLainnya: unitLainnyaController.text.trim().isNotEmpty
              ? unitLainnyaController.text.trim()
              : null,
          permintaan: selectedPermintaan!,
          pic: namaController.text.trim(),
          email: emailController.text.trim(),
          noTelpon: teleponController.text.trim(),
          keterangan: keteranganController.text.trim(),
          files: selectedFiles,
        );
      } else {
        // Kirim tanpa lampiran (JSON)
        result = await ApiService.instance.submitPermintaan(
          unitKerja: selectedUnit!,
          unitKerjaLainnya: unitLainnyaController.text.trim().isNotEmpty
              ? unitLainnyaController.text.trim()
              : null,
          permintaan: selectedPermintaan!,
          pic: namaController.text.trim(),
          email: emailController.text.trim(),
          noTelpon: teleponController.text.trim(),
          keterangan: keteranganController.text.trim(),
        );
      }

      if (!mounted) return;

      // Sukses — tampilkan dialog dengan nomor tiket
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
              const Text('Permintaan IT Anda telah berhasil dikirimkan.'),
              const SizedBox(height: 10),
              Text(
                'No. Tiket: ${result.ticketNo}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Simpan nomor tiket untuk cek status permintaan.',
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
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      // Error dari server (validasi 422, rate limit 429, dll.)
      String pesanError = e.message;

      // Jika ada error validasi per field, tampilkan detail
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
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    teleponController.dispose();
    keteranganController.dispose();
    unitLainnyaController.dispose();
    unitDisplayController.dispose();
    captchaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        title: const Text(
          'Request Permintaan Baru',
          style: TextStyle(fontWeight: FontWeight.w700, color: _navy),
        ),
        backgroundColor: _pageBackground,
        foregroundColor: _navy,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildWelcomeCard(),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE6ECF3)),
                      boxShadow: [
                        BoxShadow(
                          color: _navy.withValues(alpha: 0.045),
                          blurRadius: 20,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeading(
                          'Detail Permintaan',
                          Icons.assignment_outlined,
                        ),
                        // UNIT KERJA
                        buildLabel('Unit Kerja'),

                        TextFormField(
                          controller: unitDisplayController,
                          readOnly: true,
                          onTap: () async {
                            final picked = await showPilihUnitBottomSheet();
                            if (picked != null) {
                              setState(() {
                                selectedUnit = picked;
                                unitDisplayController.text = picked;
                                if (picked != 'Lainnya') {
                                  unitLainnyaController.clear();
                                }
                              });
                            }
                          },
                          decoration:
                              inputDecoration(
                                'Pilih Unit Kerja',
                                Icons.business,
                              ).copyWith(
                                suffixIcon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Unit kerja wajib dipilih';
                            }
                            return null;
                          },
                        ),

                        if (selectedUnit == 'Lainnya') ...[
                          const SizedBox(height: 12),

                          buildLabel('Nama Unit Kerja'),

                          TextFormField(
                            controller: unitLainnyaController,
                            decoration: inputDecoration(
                              'Masukkan nama unit kerja',
                              Icons.edit,
                            ),
                            validator: (value) {
                              if (selectedUnit == 'Lainnya' &&
                                  (value == null || value.trim().isEmpty)) {
                                return 'Nama unit kerja wajib diisi';
                              }
                              return null;
                            },
                          ),
                        ],

                        const SizedBox(height: 20),

                        // JENIS PERMINTAAN
                        buildLabel('Jenis Permintaan'),
                        DropdownButtonFormField<String>(
                          initialValue: selectedPermintaan,
                          isExpanded: true,
                          decoration: inputDecoration(
                            'Pilih Jenis Permintaan',
                            Icons.assignment_outlined,
                          ),
                          items: _availablePermintaan
                              .map(
                                (permintaan) => DropdownMenuItem<String>(
                                  value: permintaan,
                                  child: Text(
                                    permintaan,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedPermintaan = value;
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        // NAMA PENGUSUL
                        _buildSectionHeading(
                          'Informasi Pengusul',
                          Icons.person_outline_rounded,
                        ),
                        buildLabel('Nama Pengusul'),

                        TextFormField(
                          controller: namaController,
                          decoration: inputDecoration(
                            'Masukkan nama lengkap',
                            Icons.person,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama pengusul wajib diisi';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // EMAIL
                        buildLabel('Email'),

                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: inputDecoration(
                            'Masukkan email aktif',
                            Icons.email,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email wajib diisi';
                            }

                            if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$')
                                .hasMatch(value.trim())) {
                              return 'Format email tidak valid';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // NOMOR TELEPON
                        buildLabel('No. Telepon'),

                        TextFormField(
                          controller: teleponController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(13),
                          ],
                          decoration: inputDecoration(
                            'Masukkan nomor telepon (maks. 13 angka)',
                            Icons.phone,
                          ).copyWith(errorText: teleponError),
                          onChanged: (value) {
                            setState(() {
                              teleponError = null;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nomor telepon wajib diisi';
                            }

                            if (value.length < 10) {
                              return 'Nomor telepon minimal 10 angka';
                            }

                            if (value.length > 13) {
                              return 'Nomor telepon maksimal 13 angka';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // KETERANGAN
                        _buildSectionHeading(
                          'Keterangan & Lampiran',
                          Icons.attach_file_rounded,
                        ),
                        buildLabel('Keterangan'),

                        TextFormField(
                          controller: keteranganController,
                          maxLines: 4,
                          maxLength: 500,
                          decoration: inputDecoration(
                            'Jelaskan detail permintaan Anda',
                            Icons.description,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Keterangan wajib diisi';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // UPLOAD FILE
                        buildLabel('Lampiran Pendukung'),

                        const Text(
                          'Format file: PNG, JPG, JPEG, PDF. Maksimal 5 MB per file.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: Color(0xFF718096),
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: pilihFile,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Pilih File'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _blue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFFB8CBE5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                        if (selectedFiles.isNotEmpty) ...[
                          const SizedBox(height: 12),

                          ...List.generate(selectedFiles.length, (index) {
                            final file = selectedFiles[index];

                            return Card(
                              elevation: 0,
                              color: const Color(0xFFF8FAFD),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Color(0xFFE6ECF3),
                                ),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.insert_drive_file_outlined,
                                  color: _blue,
                                ),

                                title: Text(
                                  file.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                subtitle: const Text('File lampiran'),

                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Color(0xFFD94A4A),
                                  ),
                                  onPressed: () => hapusFile(index),
                                ),
                              ),
                            );
                          }),
                        ],

                        const SizedBox(height: 24),

                        // CAPTCHA
                        _buildSectionHeading(
                          'Verifikasi Pengajuan',
                          Icons.verified_user_outlined,
                        ),
                        buildLabel('Captcha'),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF4FC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFD9E5F4),
                                ),
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
                                      color: _navy,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Tooltip(
                                    message: 'Ganti captcha',
                                    child: InkWell(
                                      onTap: generateCaptcha,
                                      borderRadius: BorderRadius.circular(20),
                                      child: const Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Icon(
                                          Icons.refresh_rounded,
                                          size: 18,
                                          color: _blue,
                                        ),
                                      ),
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
                                decoration: inputDecoration(
                                  'Masukkan captcha',
                                  Icons.security,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Captcha wajib diisi';
                                  }
                                  if (value.trim() != currentCaptcha) {
                                    return 'Captcha tidak sesuai';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // TOMBOL SUBMIT
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : submitForm,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.send),
                            label: Text(
                              _isLoading ? 'Mengirim...' : 'Kirim Permintaan',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // TOMBOL KEMBALI
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              foregroundColor: _navy,
                              side: const BorderSide(color: Color(0xFFD5DFEA)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Kembali'),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [_navy, _blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -54,
            right: -42,
            child: Container(
              width: 158,
              height: 158,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -78,
            right: 46,
            child: Container(
              width: 138,
              height: 138,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _teal.withValues(alpha: 0.3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'PENGAJUAN ONLINE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),
                      const Text(
                        'Form Permintaan Layanan IT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Silakan lengkapi data berikut untuk mengajukan '
                        'permintaan layanan IT.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_rounded,
                    color: Colors.white,
                    size: 29,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: _blue),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: _navy,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // LABEL
  Widget buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: _navy,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  // INPUT DECORATION
  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: Colors.blueGrey.shade400),
      filled: true,
      fillColor: const Color(0xFFF9FBFD),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDCE4EF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDCE4EF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _blue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD94A4A)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD94A4A), width: 1.5),
      ),
    );
  }

  // BOTTOM SHEET PILIH UNIT KERJA DENGAN PENCARIAN
  Future<String?> showPilihUnitBottomSheet() {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredList = (_apiUnits ?? daftarUnit).where((unit) {
              return unit.toLowerCase().contains(query.toLowerCase());
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    // Handle Bar
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 6),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pilih Unit Kerja',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    // Search Field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: 'Cari nama unit kerja...',
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 20,
                            color: Color(0xFF64748B),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFD),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFDCE4EF),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFDCE4EF),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: _blue,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            query = val;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // List Unit Kerja
                    Expanded(
                      child: filteredList.isEmpty
                          ? const Center(
                              child: Text(
                                'Unit kerja tidak ditemukan',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            )
                          : ListView.separated(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemCount: filteredList.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: Colors.grey.shade200,
                              ),
                              itemBuilder: (context, index) {
                                final unit = filteredList[index];
                                final isSelected = selectedUnit == unit;

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  selected: isSelected,
                                  selectedTileColor: _blue.withValues(
                                    alpha: 0.08,
                                  ),
                                  title: Text(
                                    unit,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected ? _blue : _navy,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: _blue,
                                          size: 20,
                                        )
                                      : null,
                                  onTap: () {
                                    Navigator.pop(context, unit);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
