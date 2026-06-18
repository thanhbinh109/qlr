# 🌲 QLR Forest Mobile - Forest Worker App

Ứng dụng di động thuộc **Hệ thống Quản lý dữ liệu rừng & Dự án Carbon (QLR)**.
Đồng bộ dữ liệu hiện trường (nhật ký, ảnh, GPS) lên Web Server trung tâm.

## 🏗️ Kiến trúc

```
Clean Architecture (Data / Domain / Presentation)  +  BLoC  +  dartz Either<Failure,T>
```

```
lib/
├── core/            # Theme, Errors, Services (GPS/Storage/Sync), Widgets dùng chung
├── domain/          # Entities & Repository interfaces (independent của framework)
├── data/            # Models, Local/Remote DataSources, Repository implementations
└── presentation/    # BLoC + UI Pages theo từng module
    ├── auth/        # Module 3 - Đăng nhập, phân quyền
    ├── home/        # Dashboard theo vai trò (Role-based)
    ├── logbook/     # Module 8 - Nhật ký hiện trường
    ├── checkin/     # Module 6 - Check-in GPS
    ├── profile/      
    └── sync/         # Module 9 - Đồng bộ Offline -> Server
```

## 🔐 Phân quyền (RBAC)

| Vai trò | Email demo | Quyền trong App Mobile |
|---|---|---|
| **Forest Worker** | `worker@qlr.vn` | Ghi nhật ký, Check-in GPS, xem nhật ký của mình |
| **Forest Owner**  | `owner@qlr.vn`  | Xem KPI khu rừng sở hữu + nhật ký toàn bộ nhân viên (read-only) |
| **Platform Admin**| `admin@qlr.vn`  | Xem KPI toàn hệ thống + nhật ký mọi dự án |

Mật khẩu demo cho cả 3 tài khoản: **`123456`**

> Logic phân quyền: `lib/domain/auth/entities/user_entity.dart` → `UserRoleExt`
> UI thay đổi theo role tại: `lib/presentation/home/pages/home_shell.dart` & `dashboard_page.dart`

## 📡 Kết nối Database / Web Server

Mặc định app chạy với **Mock DataSources** (không cần backend) để demo được ngay.

Để kết nối **CSDL thật** qua REST API:

1. Cập nhật `lib/core/constants/api_constants.dart` → `baseUrl`
2. Trong `lib/main.dart`, đổi:
   ```dart
   AuthRemoteDataSourceMock()     -> AuthRemoteDataSourceImpl()
   LogbookRemoteDataSourceMock()  -> LogbookRemoteDataSourceImpl()
   CheckinRemoteDataSourceMock()  -> CheckinRemoteDataSourceImpl()
   ```
3. Các endpoint kỳ vọng trên server (Node/Laravel/Django... + PostgreSQL/MySQL):

   | Method | Endpoint | Mô tả | Bảng DB |
   |---|---|---|---|
   | POST | `/auth/login` | Đăng nhập, trả JWT | `users` |
   | POST | `/logbooks` (multipart) | Upload nhật ký + ảnh | `forest_logbooks`, `logbook_images` |
   | GET  | `/logbooks` | Lấy danh sách nhật ký | `forest_logbooks` |
   | POST | `/checkins` | Ghi nhận check-in/out | `field_checkins` |
   | GET  | `/health` | Kiểm tra kết nối | - |

## 📴 Offline Mode (Module 9)

- Mọi nhật ký/check-in được lưu **local trước** (key-value DB qua `StorageService`,
  production thay bằng **Isar/Hive**).
- `SyncRepository` kiểm tra mạng (`checkConnectivity()`), nếu có mạng → đẩy lên server
  và đánh dấu `isSynced = true`.
- `SyncStatusBanner` hiển thị số mục đang chờ + cho phép đồng bộ tay.

## 🚀 Chạy ứng dụng

```bash
flutter pub get
flutter run
```

## 🎨 Theme

| Token | Hex |
|---|---|
| `AppColors.primary` | `#107C41` |
| `AppColors.primaryDark` | `#0A5C30` |
| `AppColors.primaryLight` | `#E8F5EE` |

## 📦 Quyền cần thiết

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>QLR cần quyền GPS để ghi nhận vị trí hiện trường</string>
<key>NSCameraUsageDescription</key>
<string>QLR cần quyền Camera để chụp ảnh hiện trường</string>
```
