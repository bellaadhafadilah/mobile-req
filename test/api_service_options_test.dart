import 'package:flutter_test/flutter_test.dart';
import 'package:req_rsab/services/api_service.dart';

void main() {
  test('reads request types from the Laravel API response key', () {
    final options = FormOptions(
      raw: {
        'permintaan_types': [
          'Pembuatan Aplikasi Baru',
          'Pengembangan Aplikasi',
        ],
      },
    );

    expect(options.tipes, ['Pembuatan Aplikasi Baru', 'Pengembangan Aplikasi']);
  });

  test('continues to support the legacy request types key', () {
    final options = FormOptions(
      raw: {
        'tipes': ['Permintaan Data'],
      },
    );

    expect(options.tipes, ['Permintaan Data']);
  });
}
