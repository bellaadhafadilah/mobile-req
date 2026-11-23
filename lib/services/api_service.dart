// ============================================================
//  api_service.dart
//  Satu file untuk semua komunikasi ke backend Laravel.
//
//  Cara ganti Base URL:
//    Ubah nilai [baseUrl] di bawah sesuai target:
//    - Android Emulator  : http://10.0.2.2:8000/api/v1
//    - iOS Simulator     : http://127.0.0.1:8000/api/v1
//    - Perangkat fisik   : http://<IP-LAN-KOMPUTER>:8000/api/v1
//    - Production        : https://<HOST-PRODUCTION>/api/v1
// ============================================================

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

// ------------------------------------------------------------------
// KONFIGURASI — ubah hanya di sini jika ingin ganti URL atau timeout
// ------------------------------------------------------------------
class ApiConfig {
  /// Base URL harus diakhiri dengan /api/v1 (tanpa trailing slash)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://172.16.111.35:8000/api/v1',
  );

  /// Timeout per request
  static const Duration timeout = Duration(seconds: 15);
}

// ------------------------------------------------------------------
// EXCEPTION — semua error API dilempar sebagai ApiException
// ------------------------------------------------------------------
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message, {this.errors});

  final int statusCode;
  final String message;
  final Object? errors; // Map<String, List<String>> untuk error validasi 422

  @override
  String toString() => 'ApiException($statusCode): $message';

  /// Ambil pesan validasi per field, cocok untuk tampil di Form.
  /// Contoh: errors['email']?.first
  Map<String, List<String>> get fieldErrors {
    if (errors is Map) {
      return (errors as Map).map(
        (k, v) => MapEntry(
          k.toString(),
          (v as List).map((e) => e.toString()).toList(),
        ),
      );
    }
    return {};
  }
}

// ------------------------------------------------------------------
// MODEL — hasil tiket setelah submit permintaan / komplain
// ------------------------------------------------------------------
class TicketResult {
  const TicketResult({required this.ticketNo, required this.message});
  final String ticketNo;
  final String message;
}

// ------------------------------------------------------------------
// MODEL — data dashboard (ringkasan)
// ------------------------------------------------------------------
class DashboardData {
  const DashboardData({required this.raw});
  final Map<String, dynamic> raw;

  // Helper akses langsung
  dynamic operator [](String key) => raw[key];
}

// ------------------------------------------------------------------
// MODEL — item komplain di halaman daftar
// ------------------------------------------------------------------
class KomplainItem {
  const KomplainItem({required this.raw});
  final Map<String, dynamic> raw;

  String get ticketNo => raw['ticket_no']?.toString() ?? '';
  String get status => raw['status']?.toString() ?? '';
  String get keterangan => raw['keterangan']?.toString() ?? '';
  dynamic operator [](String key) => raw[key];
}

// ------------------------------------------------------------------
// MODEL — hasil paginasi daftar komplain
// ------------------------------------------------------------------
class KomplainListResult {
  const KomplainListResult({required this.items, required this.meta});
  final List<KomplainItem> items;
  final Map<String, dynamic> meta; // current_page, last_page, total, dll.
}

// ------------------------------------------------------------------
// MODEL — hasil paginasi daftar permintaan
// ------------------------------------------------------------------
class PermintaanListResult {
  const PermintaanListResult({required this.items, required this.meta});
  final List<Map<String, dynamic>> items;
  final Map<String, dynamic> meta;
}

// ------------------------------------------------------------------
// MODEL — detail tiket (permintaan atau komplain)
// ------------------------------------------------------------------
class TicketDetail {
  const TicketDetail({required this.detail, required this.history});
  final Map<String, dynamic> detail;
  final List<Map<String, dynamic>> history;
}

// ------------------------------------------------------------------
// MODEL — pilihan form dari GET options
// ------------------------------------------------------------------
class FormOptions {
  const FormOptions({required this.raw});
  final Map<String, dynamic> raw;

  List<String> get units => (raw['units'] as List? ?? [])
      .map((unit) {
        final name = unit is Map ? unit['name'] : unit;
        return name?.toString().trim() ?? '';
      })
      .where((name) => name.isNotEmpty)
      .toList();

  List<String> get tipes =>
      (raw['tipes'] as List? ?? []).map((e) => e.toString()).toList();

  List<String> get ruangans =>
      (raw['ruangans'] as List? ?? []).map((e) => e.toString()).toList();

  List<Map<String, dynamic>> get statuses => (raw['statuses'] as List? ?? [])
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList();
}

// ------------------------------------------------------------------
// INTERNAL HTTP CLIENT — tidak perlu diakses langsung dari UI
// ------------------------------------------------------------------
class _MobileApiClient {
  _MobileApiClient()
    : _baseUri = Uri.parse(
        '${ApiConfig.baseUrl.replaceFirst(RegExp(r'/$'), '')}/',
      ),
      _client = http.Client();

  final Uri _baseUri;
  final http.Client _client;

  Uri _endpoint(String path, {Map<String, String>? query}) =>
      _baseUri.resolve(path).replace(queryParameters: query);

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) async {
    final response = await _client
        .get(
          _endpoint(path, query: query),
          headers: {'Accept': 'application/json'},
        )
        .timeout(ApiConfig.timeout);
    return _decode(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final response = await _client
        .post(
          _endpoint(path),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(payload),
        )
        .timeout(ApiConfig.timeout);
    return _decode(response);
  }

  /// Decode response setelah multipart request (dipanggil dari luar)
  Map<String, dynamic> decode(http.Response response) => _decode(response);

  Uri endpoint(String path) => _endpoint(path);

  Map<String, dynamic> _decode(http.Response response) {
    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw ApiException(
        response.statusCode,
        'Respons server bukan JSON. Periksa koneksi atau URL.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw ApiException(
        response.statusCode,
        'Format respons server tidak valid.',
      );
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded['success'] != true) {
      throw ApiException(
        response.statusCode,
        decoded['message']?.toString() ?? 'Request gagal.',
        errors: decoded['errors'],
      );
    }

    return decoded;
  }
}

// ==================================================================
//  ApiService — SATU-SATUNYA class yang dipakai dari halaman UI
// ==================================================================
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  final _MobileApiClient _api = _MobileApiClient();

  // ----------------------------------------------------------------
  // HEALTH — ping untuk cek koneksi ke backend
  // ----------------------------------------------------------------

  /// Cek apakah server bisa dijangkau.
  /// Lempar [ApiException] jika gagal.
  Future<bool> ping() async {
    await _api.get('ping');
    return true;
  }

  // ----------------------------------------------------------------
  // OPTIONS — data pilihan untuk isi form (unit, tipe, dll.)
  // ----------------------------------------------------------------

  /// Ambil pilihan form: unit kerja, tipe permintaan, ruangan, status.
  Future<FormOptions> getOptions() async {
    final res = await _api.get('options');
    return FormOptions(raw: res['data'] as Map<String, dynamic>? ?? {});
  }

  // ----------------------------------------------------------------
  // DASHBOARD — ringkasan permintaan dan komplain
  // ----------------------------------------------------------------

  /// Ambil ringkasan dashboard.
  /// [tanggalAwal] dan [tanggalAkhir] format YYYY-MM-DD (opsional).
  Future<DashboardData> getDashboard({
    String? tanggalAwal,
    String? tanggalAkhir,
  }) async {
    final query = <String, String>{};
    if (tanggalAwal != null) query['tanggal_awal'] = tanggalAwal;
    if (tanggalAkhir != null) query['tanggal_akhir'] = tanggalAkhir;

    final res = await _api.get(
      'dashboard',
      query: query.isEmpty ? null : query,
    );
    return DashboardData(raw: res['data'] as Map<String, dynamic>? ?? {});
  }

  // ----------------------------------------------------------------
  // PERMINTAAN — kirim form & cek status tiket
  // ----------------------------------------------------------------

  /// Kirim form permintaan IT (tanpa lampiran).
  ///
  /// - [unitKerja]       : unit kerja pelapor
  /// - [unitKerjaLainnya]: wajib diisi jika [unitKerja] == 'Lainnya'
  /// - [permintaan]      : jenis permintaan (harus ada di GET options)
  /// - [pic]             : nama pengusul
  /// - [email]           : email aktif
  /// - [noTelpon]        : nomor telepon
  /// - [keterangan]      : deskripsi permintaan
  Future<TicketResult> submitPermintaan({
    required String unitKerja,
    String? unitKerjaLainnya,
    required String permintaan,
    required String pic,
    required String email,
    required String noTelpon,
    required String keterangan,
  }) async {
    final payload = <String, dynamic>{
      'unit_kerja': unitKerja,
      'permintaan': permintaan,
      'pic': pic,
      'email': email,
      'no_telpon': noTelpon,
      'keterangan': keterangan,
    };
    if (unitKerja == 'Lainnya' && unitKerjaLainnya != null) {
      payload['unit_kerja_lainnya'] = unitKerjaLainnya;
    }

    final res = await _api.postJson('permintaan', payload);
    final data = res['data'] as Map<String, dynamic>;
    return TicketResult(
      ticketNo: data['ticket_no']?.toString() ?? '',
      message: res['message']?.toString() ?? 'Permintaan berhasil dikirim.',
    );
  }

  /// Kirim form permintaan IT DENGAN lampiran file (multipart).
  ///
  /// Gunakan ini jika user memilih file via FilePicker.
  /// Batas: maks 10 file, 5 MB per file, format JPG/JPEG/PNG/PDF.
  Future<TicketResult> submitPermintaanWithFiles({
    required String unitKerja,
    String? unitKerjaLainnya,
    required String permintaan,
    required String pic,
    required String email,
    required String noTelpon,
    required String keterangan,
    required List<PlatformFile> files,
  }) async {
    if (files.length > 10) {
      throw const ApiException(0, 'Maksimal 10 file yang dapat dilampirkan.');
    }

    const maxSizeBytes = 5 * 1024 * 1024; // 5 MB
    for (final f in files) {
      if (f.size > maxSizeBytes) {
        throw ApiException(0, 'File "${f.name}" melebihi batas ukuran 5 MB.');
      }
    }

    final request = http.MultipartRequest('POST', _api.endpoint('permintaan'))
      ..headers['Accept'] = 'application/json';

    request.fields['unit_kerja'] = unitKerja;
    request.fields['permintaan'] = permintaan;
    request.fields['pic'] = pic;
    request.fields['email'] = email;
    request.fields['no_telpon'] = noTelpon;
    request.fields['keterangan'] = keterangan;
    if (unitKerja == 'Lainnya' && unitKerjaLainnya != null) {
      request.fields['unit_kerja_lainnya'] = unitKerjaLainnya;
    }

    for (final file in files) {
      final path = file.path;
      if (path == null) {
        throw ApiException(0, 'Path file "${file.name}" tidak tersedia.');
      }
      request.files.add(
        await http.MultipartFile.fromPath('file_upload[]', path),
      );
    }

    final streamed = await request.send().timeout(ApiConfig.timeout);
    final response = await http.Response.fromStream(streamed);
    final decoded = _api.decode(response);
    final data = decoded['data'] as Map<String, dynamic>;
    return TicketResult(
      ticketNo: data['ticket_no']?.toString() ?? '',
      message: decoded['message']?.toString() ?? 'Permintaan berhasil dikirim.',
    );
  }

  /// Cek status tiket permintaan berdasarkan nomor tiket.
  Future<TicketDetail> getPermintaanStatus(String ticketNo) async {
    final res = await _api.get(
      'permintaan/status/${Uri.encodeComponent(ticketNo)}',
    );
    final data = res['data'] as Map<String, dynamic>;
    return TicketDetail(
      detail: Map<String, dynamic>.from(data['detail'] as Map? ?? {}),
      history: (data['history'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }

  /// Ambil daftar permintaan dengan filter tanggal dan paginasi opsional.
  Future<PermintaanListResult> getPermintaanList({
    String? tanggalAwal,
    String? tanggalAkhir,
    int page = 1,
    int perPage = 15,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (tanggalAwal != null) query['tanggal_awal'] = tanggalAwal;
    if (tanggalAkhir != null) query['tanggal_akhir'] = tanggalAkhir;

    final res = await _api.get('permintaan', query: query);
    final rawList = (res['data'] as List? ?? []);
    return PermintaanListResult(
      items: rawList
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      meta: Map<String, dynamic>.from(res['meta'] as Map? ?? {}),
    );
  }

  // ----------------------------------------------------------------
  // KOMPLAIN — kirim form & cek status tiket & daftar komplain
  // ----------------------------------------------------------------

  /// Kirim form komplain IT — pelapor INTERNAL.
  ///
  /// - [unitKerjaInternal]: unit kerja pelapor
  /// - [picInternal]      : nama pelapor
  /// - [permintaan]       : kategori (Hardware, Jaringan, Software, dll.)
  /// - [noTelepon]        : nomor telepon
  /// - [kerusakan]        : judul kerusakan singkat
  /// - [keterangan]       : deskripsi detail
  Future<TicketResult> submitKomplainInternal({
    required String unitKerjaInternal,
    required String picInternal,
    required String permintaan,
    required String noTelepon,
    required String kerusakan,
    required String keterangan,
  }) async {
    final res = await _api.postJson('komplain', {
      'jenis_pelapor': 'internal',
      'unit_kerja_internal': unitKerjaInternal,
      'pic_internal': picInternal,
      'permintaan': permintaan,
      'no_telepon': noTelepon,
      'kerusakan': kerusakan,
      'keterangan': keterangan,
    });
    final data = res['data'] as Map<String, dynamic>;
    return TicketResult(
      ticketNo: data['ticket_no']?.toString() ?? '',
      message: res['message']?.toString() ?? 'Komplain berhasil dikirim.',
    );
  }

  /// Kirim form komplain IT — pelapor EKSTERNAL.
  ///
  /// - [lokasiExternal]: lokasi / ruangan pelapor
  /// - [picEksternal]  : nama pelapor
  /// - [permintaan]    : kategori (Hardware, Jaringan, Software, dll.)
  /// - [noTelepon]     : nomor telepon
  /// - [kerusakan]     : judul kerusakan singkat
  /// - [keterangan]    : deskripsi detail
  Future<TicketResult> submitKomplainEksternal({
    required String lokasiExternal,
    required String picEksternal,
    required String permintaan,
    required String noTelepon,
    required String kerusakan,
    required String keterangan,
  }) async {
    final res = await _api.postJson('komplain', {
      'jenis_pelapor': 'external',
      'lokasi_external': lokasiExternal,
      'pic_eksternal': picEksternal,
      'permintaan': permintaan,
      'no_telepon': noTelepon,
      'kerusakan': kerusakan,
      'keterangan': keterangan,
    });
    final data = res['data'] as Map<String, dynamic>;
    return TicketResult(
      ticketNo: data['ticket_no']?.toString() ?? '',
      message: res['message']?.toString() ?? 'Komplain berhasil dikirim.',
    );
  }

  /// Ambil daftar komplain dengan filter opsional.
  ///
  /// - [search]       : cari berdasarkan kata kunci / nomor tiket
  /// - [statusId]     : filter berdasarkan ID status
  /// - [unitKerja]    : filter berdasarkan unit kerja
  /// - [tanggalAwal]  : format YYYY-MM-DD
  /// - [tanggalAkhir] : format YYYY-MM-DD
  /// - [page]         : halaman (default 1)
  /// - [perPage]      : jumlah per halaman (maks 50)
  Future<KomplainListResult> getKomplainList({
    String? search,
    int? statusId,
    String? unitKerja,
    String? tanggalAwal,
    String? tanggalAkhir,
    int page = 1,
    int perPage = 15,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (statusId != null) query['status_id'] = statusId.toString();
    if (unitKerja != null && unitKerja.isNotEmpty) {
      query['unit_kerja'] = unitKerja;
    }
    if (tanggalAwal != null) query['tanggal_awal'] = tanggalAwal;
    if (tanggalAkhir != null) query['tanggal_akhir'] = tanggalAkhir;

    final res = await _api.get('komplain', query: query);
    final rawList = (res['data'] as List? ?? []);
    return KomplainListResult(
      items: rawList
          .map((e) => KomplainItem(raw: Map<String, dynamic>.from(e as Map)))
          .toList(),
      meta: Map<String, dynamic>.from(res['meta'] as Map? ?? {}),
    );
  }

  /// Cek status tiket komplain berdasarkan nomor tiket.
  Future<TicketDetail> getKomplainStatus(String ticketNo) async {
    final res = await _api.get(
      'komplain/status/${Uri.encodeComponent(ticketNo)}',
    );
    final data = res['data'] as Map<String, dynamic>;
    return TicketDetail(
      detail: Map<String, dynamic>.from(data['detail'] as Map? ?? {}),
      history: (data['history'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }

  /// Kirim rating/ulasan untuk tiket komplain.
  ///
  /// Hanya bisa dikirim jika status_id == 2 dan ulasan_at == null.
  /// - [rating]         : nilai 1–5
  /// - [ulasanKategori] : kategori ulasan (mis. 'Baik Sekali')
  /// - [ulasan]         : komentar opsional
  Future<bool> submitUlasan({
    required String ticketNo,
    required int rating,
    required String ulasanKategori,
    String? ulasan,
  }) async {
    final payload = <String, dynamic>{
      'rating': rating,
      'ulasan_kategori': ulasanKategori,
    };
    if (ulasan != null && ulasan.isNotEmpty) payload['ulasan'] = ulasan;

    await _api.postJson(
      'komplain/${Uri.encodeComponent(ticketNo)}/ulasan',
      payload,
    );
    return true;
  }
}
