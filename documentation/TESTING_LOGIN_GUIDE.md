# 🔐 TESTING REAL LOGIN - STEP BY STEP

## ✅ Prerequisites

Pastikan sudah selesai:
1. ✅ Database setup via `setup_production.php`
2. ✅ XAMPP running (Apache + MySQL)
3. ✅ Backend PHP files ada di folder yang benar
4. ✅ Flutter SDK installed

---

## 📍 Step 1: Verify Backend is Accessible

### Cek apakah backend API berjalan:

**Via Browser:**
```
http://localhost/jawara/backend/auth.php
```

Jika berhasil, akan melihat error JSON (karena POST tanpa data):
```json
{"success":false,"error":"Email and password required"}
```

**Via cURL (Command Line):**
```bash
curl -X POST http://localhost/jawara/backend/auth.php \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@jawara.com","password":"password123"}'
```

Expected response:
```json
{"success":true,"data":{...user data...}}
```

---

## 🚀 Step 2: Run Flutter App

### Development (Emulator/Device):

```bash
cd d:\CloneGithub\New_PBL_Jawara\pbl_new

# List available devices
flutter devices

# Run app
flutter run
```

### If using Android Emulator:
Update `api_config.dart` baseUrl:
```dart
static const String baseUrl = 'http://10.0.2.2/jawara/backend';
```

### If using Physical Device:
Replace `localhost` dengan IP address komputer Anda:
```dart
static const String baseUrl = 'http://192.168.X.X/jawara/backend';
```

---

## 🧪 Step 3: Test Login

### Test Case 1: Admin Login

1. Open app
2. Input:
   - Email: `admin@jawara.com`
   - Password: `password123`
3. Click "Masuk" button
4. **Expected Result:** 
   - ✅ Loading spinner appears
   - ✅ Navigate to **Admin Dashboard**

### Test Case 2: RT/RW Login

1. Input:
   - Email: `budi.rt05@jawara.com`
   - Password: `password123`
2. Click "Masuk" button
3. **Expected Result:**
   - ✅ Loading spinner appears
   - ✅ Navigate to **RT Dashboard** (Kelurahan/RT Management)

### Test Case 3: Warga Login

1. Input:
   - Email: `lisa@jawara.com`
   - Password: `password123`
2. Click "Masuk" button
3. **Expected Result:**
   - ✅ Loading spinner appears
   - ✅ Navigate to **Warga Home** (Beranda screen)

### Test Case 4: Invalid Credentials

1. Input:
   - Email: `admin@jawara.com`
   - Password: `wrongpassword`
2. Click "Masuk" button
3. **Expected Result:**
   - ✅ Error message appears
   - ✅ Stay on login screen

---

## 🔍 Step 4: Verify Dashboard Access

### Admin Dashboard Should Show:
- [ ] RT/RW management
- [ ] User statistics
- [ ] Marketplace analytics
- [ ] ML detection statistics
- [ ] System settings

### RT Dashboard Should Show:
- [ ] Warga list di RT tersebut
- [ ] Verification approval queue
- [ ] Activity reports
- [ ] Community announcements

### Warga Home Should Show:
- [ ] Product marketplace
- [ ] Chat with sellers
- [ ] Product uploads
- [ ] Detection history

---

## 🐛 Debugging

### Jika login gagal - cek log:

#### 1. Check Backend Log
```bash
# Check if backend getting request
# Add logging di auth.php
echo "Received: " . print_r($_POST, true);
```

#### 2. Check Flutter Console
Look for error messages like:
```
Connection error: ...
Failed to login: ...
```

#### 3. Check Database
```sql
-- Verify user exists
SELECT id, name, email, user_type FROM users WHERE email='admin@jawara.com';

-- Should return:
-- admin001 | Budi Santoso | admin@jawara.com | admin
```

#### 4. Test Password Hash
```php
<?php
// Verify password hash
$password = "password123";
$hash = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi';

if (password_verify($password, $hash)) {
    echo "Password is correct!";
} else {
    echo "Password is wrong!";
}
?>
```

---

## 📊 Expected Database State After Setup

```sql
SELECT COUNT(*) as total_users FROM users;
-- Expected: 14

SELECT user_type, COUNT(*) as count FROM users GROUP BY user_type;
-- Expected:
-- admin | 1
-- rt    | 5
-- warga | 8
```

---

## ✅ Success Checklist

- [ ] Backend API accessible at http://localhost/jawara/backend/auth.php
- [ ] Admin login works → Admin Dashboard
- [ ] RT login works → RT Dashboard
- [ ] Warga login works → Warga Home
- [ ] Invalid credentials show error
- [ ] Database has 14 seed users
- [ ] No hardcoded demo users in production

---

## 🚨 Common Issues & Solutions

### Issue: "Connection error: Connection refused"
**Solution:**
- [ ] Check XAMPP running
- [ ] Check baseUrl di api_config.dart
- [ ] Ensure backend folder accessible

### Issue: "Email and password required" (even with correct credentials)
**Solution:**
- [ ] Check Content-Type header is `application/json`
- [ ] Check email/password fields not empty
- [ ] Verify auth.php receiving POST request

### Issue: "User not found"
**Solution:**
- [ ] Run setup_production.php again
- [ ] Verify user exists in database
- [ ] Check case sensitivity (email should be lowercase)

### Issue: "Password incorrect" (with correct password)
**Solution:**
- [ ] Check password hash in database
- [ ] Verify password_verify() function working
- [ ] Try default password: `password123`

---

## 🎯 Next Steps After Testing

1. ✅ Change default passwords for security
2. ✅ Update API endpoint for production server
3. ✅ Enable HTTPS for API
4. ✅ Setup proper error logging
5. ✅ Configure Firebase for notifications
6. ✅ Test all user roles and features
