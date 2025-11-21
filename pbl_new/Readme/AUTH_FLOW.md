# Authentication Flow - Jawara Marketplace

## Overview
Sistem autentikasi lengkap dengan splash screen, login, dan registrasi yang sudah diintegrasikan ke dalam aplikasi Jawara Marketplace.

## Screens Implemented

### 1. Splash Screen (splash_screen.dart)
- **Warna Background**: Blue (#2D3FE3)
- **Logo**: Shopping bag icon dengan sparkle effect
- **Branding**: "Jawara" dengan subtitle "MARKETPLACE PAKAIAN"
- **Tagline**: "Pasar lokal untuk Komunitas RT/RW Indonesia"
- **Loading Indicator**: 3 dots animation
- **Auto-redirect**: Navigasi otomatis ke Login Screen setelah 3 detik

### 2. Login Screen (login_screen.dart)
**Tab Navigation**: Masuk (active) | Daftar

**Form Fields**:
- Email (dengan icon email)
- Password (dengan visibility toggle)
- Lupa kata sandi link

**Buttons**:
- Masuk button (primary blue dengan arrow icon)
- Demo Mode buttons: Warga | RT/RW | Admin

**Features**:
- Tab switching ke Register Screen
- Password visibility toggle
- Demo login untuk testing
- Auto-redirect ke MainScreen setelah login

### 3. Register Screen (register_screen.dart)
**Tab Navigation**: Masuk | Daftar (active)

**Role Selection** (dengan icon):
- Warga (person icon)
- RT/RW (groups icon)
- Admin (admin_panel_settings icon)

**Form Fields**:
- Nama Lengkap
- Email
- Password (dengan visibility toggle)

**Buttons**:
- Daftar Sekarang button (primary blue dengan arrow icon)
- Demo Mode buttons: Warga | RT/RW | Admin

**Features**:
- Interactive role selection dengan visual feedback
- Tab switching ke Login Screen
- Password visibility toggle
- Registration success message

## Flow Diagram

```
App Start
    ↓
Splash Screen (3 seconds)
    ↓
Login Screen
    ├── Tab → Register Screen
    │           ├── Select Role (Warga/RT-RW/Admin)
    │           ├── Fill Form
    │           ├── Daftar → Show Success → Back to Login
    │           └── Demo Login → Main Screen
    │
    ├── Login → Main Screen
    └── Demo Login → Main Screen
```

## Navigation Structure

1. **SplashScreen**
   - Auto-navigate → LoginScreen (3 detik)

2. **LoginScreen**
   - Tab "Daftar" → RegisterScreen
   - Button "Masuk" → MainScreen
   - Demo buttons → MainScreen

3. **RegisterScreen**
   - Tab "Masuk" → LoginScreen
   - Button "Daftar Sekarang" → LoginScreen (dengan success message)
   - Demo buttons → LoginScreen

## Color Scheme

- **Primary Blue**: #2D3FE3
- **Gold/Yellow**: #FFD700 / #FFAA00
- **Background**: Grey[50]
- **Card Background**: White
- **Input Background**: Grey[100]

## Demo Mode

Untuk testing tanpa backend:
- **Warga**: Login sebagai user biasa
- **RT/RW**: Login sebagai pengurus RT/RW
- **Admin**: Login sebagai admin

## Files Modified

1. `lib/main.dart` - Changed home to SplashScreen
2. `lib/screens/splash_screen.dart` - NEW
3. `lib/screens/login_screen.dart` - NEW
4. `lib/screens/register_screen.dart` - NEW

## Testing

Jalankan aplikasi dengan:
```bash
flutter run
```

Flow testing:
1. ✅ Splash screen muncul selama 3 detik
2. ✅ Auto-redirect ke Login Screen
3. ✅ Switch tab ke Register Screen
4. ✅ Role selection (Warga/RT-RW/Admin)
5. ✅ Form input dengan password toggle
6. ✅ Demo mode login bekerja
7. ✅ Navigation ke MainScreen berhasil

## Future Enhancements

- [ ] Backend integration untuk login/register
- [ ] Form validation
- [ ] Email verification
- [ ] Password strength indicator
- [ ] Remember me functionality
- [ ] Social login (Google, Facebook)
- [ ] OTP verification
