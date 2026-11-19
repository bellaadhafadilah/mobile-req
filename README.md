# req_rsab

A new Flutter project.

## Backend API

Aplikasi memakai endpoint `/api/v1` tanpa autentikasi. Android Emulator memakai
default `http://10.0.2.2:8010/api/v1`. Untuk Android fisik, jalankan aplikasi
dengan alamat IPv4 komputer/server backend yang berada di jaringan yang sama:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8010/api/v1
```

Ganti `192.168.1.20` dan port dengan alamat server yang sebenarnya. Pastikan
backend menerima koneksi dari jaringan (bukan hanya `127.0.0.1`) dan firewall
mengizinkan port tersebut. Untuk production, gunakan URL HTTPS.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
