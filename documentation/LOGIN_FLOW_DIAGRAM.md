# 🔐 Login Flow Diagram - Production Setup

## Before (❌ Demo Mode)

```
┌─────────────────────────────────────────────────────────────┐
│                      LOGIN SCREEN                           │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Email:    admin@jawara.com                                 │
│  Password: ••••••••••                                         │
│  [MASUK Button]                                              │
│                                                               │
│  [Demo Warga] [Demo RT/RW] [Demo Admin]                      │
│                                                               │
└─────────────────────────────────────────────────────────────┘
                           ↓
               ❌ HARDCODED DEMO USER
               (Ignores actual input)
                           ↓
        ┌──────────┬──────────┬──────────┐
        ↓          ↓          ↓          ↓
    Main Screen  (Same for all)
    (Warga only)
    
    ❌ Admin tidak masuk Admin Dashboard
    ❌ RT tidak masuk RT Dashboard
    ❌ Password tidak divalidasi
```

---

## After (✅ Real Authentication)

```
┌─────────────────────────────────────────────────────────────┐
│                      LOGIN SCREEN                           │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Email:    [input field with validation]                    │
│  Password: [input field with toggle show/hide]              │
│  [MASUK Button with Loading Indicator]                       │
│                                                               │
│  Demo buttons (optional, for testing only)                   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
                           ↓
             ✅ VALIDATE INPUT (not empty)
                           ↓
        ┌──────────────────────────────────┐
        │   SEND TO BACKEND API            │
        │  POST /jawara/backend/auth.php   │
        │  {email, password}               │
        └──────────────────────────────────┘
                           ↓
        ┌──────────────────────────────────┐
        │   BACKEND VALIDATION             │
        │  1. Hash password with bcrypt    │
        │  2. Compare with DB              │
        │  3. Return user_type             │
        └──────────────────────────────────┘
                           ↓
                ✅ LOGIN SUCCESS
                           ↓
        ┌────────────────┬────────────────┬────────────────┐
        ↓                ↓                ↓                ↓
    user_type='admin' |'rt'           |'warga'
        ↓                ↓                ↓
  AdminMainScreen   RtMainScreen    MainScreen
  ✅ Dashboard      ✅ Dashboard    ✅ Warga Home
    Management       RT/RW           Beranda
```

---

## Database Connection Flow

```
┌──────────────────┐
│   Flutter App    │
│  (login_screen)  │
└────────┬─────────┘
         │
         │ POST /auth.php
         │ {email, password}
         ↓
┌──────────────────────────────┐
│    Backend API (auth.php)     │
├──────────────────────────────┤
│ 1. Receive email & password  │
│ 2. Check database for user   │
│ 3. Verify password hash      │
│ 4. Return user data          │
└────────┬─────────────────────┘
         │
         │ JSON Response
         │ {success, user_type, ...}
         ↓
┌──────────────────┐
│   Flutter App    │
│  (auth_service)  │
├──────────────────┤
│ 1. Parse response│
│ 2. Save user     │
│ 3. Route by type │
└────────┬─────────┘
         │
    ┌────┴────┬────────────┬──────────┐
    ↓         ↓            ↓          ↓
  admin      rt          warga
    ↓         ↓            ↓          ↓
┌─────┐  ┌──────┐  ┌─────────┐    Main
│Admin│  │RT    │  │Warga    │   Screen
│Dash-│  │Dash- │  │Beranda  │   (demo)
│board│  │board │  │         │
└─────┘  └──────┘  └─────────┘

✅ All 3 go to correct dashboard
```

---

## Data Flow - User Authentication

```
STEP 1: INPUT
┌───────────────────────────────────┐
│ Email: admin@jawara.com           │
│ Password: password123             │
│ [MASUK] Button → _handleLogin()   │
└───────────────────────────────────┘
           ↓
STEP 2: VALIDATION
┌───────────────────────────────────┐
│ ✓ Email not empty?                │
│ ✓ Password not empty?             │
│ ✓ Show loading indicator          │
└───────────────────────────────────┘
           ↓
STEP 3: API CALL
┌─────────────────────────────────────────┐
│ POST http://localhost/jawara/backend/   │
│       auth.php                          │
│ Headers: {Content-Type: application/json}
│ Body: {email, password}                 │
│ Timeout: 30 seconds                     │
└─────────────────────────────────────────┘
           ↓
STEP 4: BACKEND PROCESSING
┌────────────────────────────────┐
│ File: backend/auth.php         │
│ 1. Receive POST data           │
│ 2. Query DB: SELECT * FROM     │
│    users WHERE email = ?        │
│ 3. Verify: password_verify()   │
│ 4. Return: user data + type    │
└────────────────────────────────┘
           ↓
STEP 5: RESPONSE
┌──────────────────────────────────┐
│ {                                │
│   "success": true,               │
│   "data": {                      │
│     "id": "admin001",            │
│     "name": "Budi Santoso",      │
│     "email": "admin@jawara.com", │
│     "user_type": "admin",        │
│     ...                          │
│   }                              │
│ }                                │
└──────────────────────────────────┘
           ↓
STEP 6: HANDLE RESPONSE
┌────────────────────────────────┐
│ ✓ success == true?             │
│ ✓ Save user to memory          │
│ ✓ Check user_type              │
│ ✓ Hide loading indicator       │
└────────────────────────────────┘
           ↓
STEP 7: NAVIGATE
┌──────────────────────────────────┐
│ if (user.userType == 'admin')    │
│   → AdminMainScreen()            │
│ else if (user.userType == 'rt')  │
│   → RtMainScreen()               │
│ else                             │
│   → MainScreen('warga')          │
└──────────────────────────────────┘
           ↓
✅ LOGGED IN TO CORRECT DASHBOARD
```

---

## Database Schema (After setup_production.php)

```
USERS TABLE (14 records)
┌──────────┬──────────────────┬─────────────────┬──────────┐
│ id       │ name             │ email           │ usertype │
├──────────┼──────────────────┼─────────────────┼──────────┤
│ admin001 │ Budi Santoso     │ admin@...       │ admin    │
│ rt001    │ Pak Ahmad RT 01  │ ahmad.rt01@...  │ rt       │
│ rt002    │ Pak Budi RT 02   │ budi.rt02@...   │ rt       │
│ rt003    │ Pak Candra RT 03 │ candra.rt03@... │ rt       │
│ rt004    │ Pak Dedi RT 04   │ dedi.rt04@...   │ rt       │
│ rt005    │ Pak Budi RT 05   │ budi.rt05@...   │ rt       │
│ warga001 │ Toko Sepatu Jaya │ sepatu@...      │ warga    │
│ warga002 │ Ibu Lisa         │ lisa@...        │ warga    │
│ warga004 │ Dimas Pratama    │ dimas@...       │ warga    │
│ warga006 │ Sari Wulandari   │ sari@...        │ warga    │
│ warga007 │ Pak Eko          │ eko@...         │ warga    │
│ warga010 │ Ibu Siti Aminah  │ aminah@...      │ warga    │
│ warga011 │ Toko Elektronik  │ elektronik@...  │ warga    │
│ warga012 │ Pak Herman       │ herman@...      │ warga    │
└──────────┴──────────────────┴─────────────────┴──────────┘

Password Hash (all): $2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi
Plain password: password123
```

---

## Production Setup Flow

```
You Run:
$ php setup_production.php
        ↓
setup_production.php:
┌─────────────────────────────────────────┐
│ 1. Create database marketplace_rtrw     │
│ 2. Run migration 01_auth_users.sql      │
│ 3. Run migration 02_products_cats...    │
│ 4. Run migration 03_chat_messages...    │
│ 5. Run migration 04_transactions...     │
│ 6. Run migration 05_ml_detections...    │
│ 7. Run migration 06_rt_metrics...       │
│ 8. Verify all tables created            │
│ 9. Display seed credentials             │
│ 10. Check backend connectivity          │
└─────────────────────────────────────────┘
        ↓
✅ DATABASE PRODUCTION READY
   14 seed users
   All tables created
   Ready for real testing
```

---

## Timeline: Before vs After

### ❌ BEFORE (Demo Mode)
```
Time: 0s
↓ Open app
↓ See login screen (but it's fake)
↓ Click demo buttons for hardcoded users
↓ Always goes to MainScreen/Warga
✗ Can't test admin or RT flows
✗ Ignores actual login credentials
```

### ✅ AFTER (Production Ready)
```
Time: 0s → Run setup_production.php
Time: 5s → Database ready with 14 users
Time: 10s → XAMPP started
Time: 15s → Flutter app running
Time: 20s → Enter admin@jawara.com + password123
Time: 21s → Loading...
Time: 23s → ✅ Navigate to Admin Dashboard
         ✅ Real authentication verified
         ✅ User data loaded from database
```

---

## Key Improvements Summary

| Feature | Before | After |
|---------|--------|-------|
| **Login** | Hardcoded demo | Real authentication ✅ |
| **Database** | No setup script | Auto setup script ✅ |
| **Credentials** | Not validated | Validated with bcrypt ✅ |
| **Routing** | Always MainScreen | By user_type ✅ |
| **Testing** | Limited to demo users | 14 real users ✅ |
| **Production Ready** | ❌ No | ✅ Yes |

