# Gôn! Quiz – Thách thức tri thức bóng đá Việt Nam ⚽

Ứng dụng quiz bóng đá dành cho người hâm mộ Việt Nam. Thử thách kiến thức về V.League, World Cup, Champions League và các huyền thoại bóng đá.

---

## Tính năng

- **4 chủ đề quiz**: V.League, World Cup, Champions League, Huyền thoại
- **Quick Play**: Trộn ngẫu nhiên câu hỏi từ tất cả chủ đề
- **Bảng điểm**: Lưu lịch sử 20 trận gần nhất
- **Điểm cao**: Theo dõi kỷ lục cá nhân
- **Hoàn toàn offline**: Không cần internet
- **Không thu thập dữ liệu**: Mọi dữ liệu chỉ lưu trên thiết bị

---

## Công nghệ

- **Flutter** – framework đa nền tảng
- **Riverpod** – quản lý state
- **SharedPreferences** – lưu trữ cục bộ
- **flutter_animate** – hiệu ứng animation

---

## Cài đặt & Chạy

```bash
# Cài dependencies
flutter pub get

# Chạy debug
flutter run

# Build APK release
flutter build apk --release
```

### Tạo lại icon

```bash
python3 scripts/generate_assets.py
dart run flutter_launcher_icons
```

---

## Cấu trúc thư mục

```
lib/
├── core/           # Theme, constants
├── data/           # Models, repositories
└── features/
    ├── home/       # Màn hình chính
    ├── quiz/       # Màn hình quiz
    ├── result/     # Kết quả
    ├── leaderboard/# Bảng điểm
    └── settings/   # Về ứng dụng, chính sách
assets/
├── images/         # Icon app
└── sounds/         # Âm thanh
scripts/
└── generate_assets.py # Tạo icon & banner bằng Python/Pillow
```

---

## Chính sách bảo mật

Ứng dụng **không thu thập bất kỳ thông tin cá nhân nào**. Toàn bộ dữ liệu (điểm số, lịch sử chơi) được lưu cục bộ trên thiết bị và có thể xoá bằng cách gỡ cài đặt ứng dụng.

---

## Liên hệ

Email: support@gonquiz.app  
Quốc gia: Việt Nam 🇻🇳

---

© 2025 Gôn! Quiz. Made with ❤️ tại Việt Nam.
