# Features Structure

Struktur folder ini mengorganisir kode berdasarkan fitur dan role user untuk memudahkan development dan debugging.

## Struktur Folder

```
features/
├── auth/           # Fitur Authentication
│   └── screens/
│       ├── login_screen.dart
│       ├── register_screen.dart
│       └── splash_screen.dart
│
├── warga/          # Fitur untuk User Warga
│   ├── screens/
│   │   ├── beranda_screen.dart          # Marketplace home
│   │   ├── jualan_screen.dart           # Product management
│   │   ├── add_product_screen.dart      # Add new product
│   │   ├── product_detail_screen.dart   # Product details
│   │   ├── camera_detection_screen.dart # ML detection
│   │   ├── chat_screen.dart             # Chat list
│   │   ├── chat_detail_screen.dart      # Chat conversation
│   │   └── profil_screen.dart           # Warga profile
│   └── widgets/
│       └── product_card.dart
│
├── rt/             # Fitur untuk User RT/RW
│   └── screens/
│       ├── rt_main_screen.dart          # RT navigation container
│       ├── rt_dashboard_screen.dart     # RT metrics & overview
│       ├── rt_warga_list_screen.dart    # Warga management
│       ├── rt_approval_screen.dart      # Product approval queue
│       └── rt_profil_screen.dart        # RT profile
│
└── admin/          # Fitur untuk User Admin
    └── screens/
        ├── admin_main_screen.dart       # Admin navigation container
        ├── admin_dashboard_screen.dart  # Global metrics
        └── admin_profile_screen.dart    # Admin profile
```

## Core Components

```
core/
├── models/         # Data models (UserModel, ProductModel, dll)
├── services/       # Business logic & API calls
└── config/         # App configuration
```

## Shared Components

```
shared/
└── widgets/        # Reusable widgets across features
```

## Cara Debug per User Role

### Debug Warga Features:
- Fokus ke folder `features/warga/`
- Main screens: beranda, jualan, chat, profil
- Widgets: product_card

### Debug RT Features:
- Fokus ke folder `features/rt/`
- Main screens: dashboard, warga_list, approval, profil
- Navigation: rt_main_screen

### Debug Admin Features:
- Fokus ke folder `features/admin/`
- Main screens: dashboard, profile
- Navigation: admin_main_screen

### Debug Auth:
- Fokus ke folder `features/auth/`
- Screens: login, register, splash

## Import Paths

Gunakan import relatif atau absolute dari lib root:

```dart
// Auth screens
import 'package:pbl_new/features/auth/screens/login_screen.dart';

// Warga screens
import 'package:pbl_new/features/warga/screens/beranda_screen.dart';

// RT screens
import 'package:pbl_new/features/rt/screens/rt_dashboard_screen.dart';

// Admin screens
import 'package:pbl_new/features/admin/screens/admin_dashboard_screen.dart';

// Core services & models
import 'package:pbl_new/core/services/auth_service.dart';
import 'package:pbl_new/core/models/user_model.dart';
```
