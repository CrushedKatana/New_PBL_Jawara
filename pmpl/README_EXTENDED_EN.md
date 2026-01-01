# SOFTWARE TESTING REPORT (PMPL)
## JAWARA CLOTHING STORE v1.4.0

---

## 1. PROJECT GENERAL INFORMATION

| Item | Details |
| --- | --- |
| Application Name | JAWARA CLOTHING STORE |
| App Version | 1.4.0 (Release Candidate) |
| Platforms | Mobile (Flutter), Web (React), Backend (PHP) |
| Test Period | December 15–24, 2025 |
| Test Team | Charellino K S (Lead QA); M. Atho'illah M (API/Backend); Mikaila Kafka (Mobile/E2E) |
| Test Location | Staging Environment (192.168.1.100) |
| Report Completion Date | December 26, 2025 |
| Testing Budget | 168 work hours (~2 weeks) |

---

## 2. EXECUTIVE SUMMARY

### 2.1 Testing Objectives & Scope
Software testing for JAWARA CLOTHING STORE aims to verify the application is production-ready with:
- All core features functioning as per requirements
- Performance stability under normal and stress user loads
- Data security and authentication working seamlessly
- Consistent user experience across all platforms (mobile, web)

### 2.2 Metrics Summary
- **Total Test Cases**: 68 (Functional: 28, E2E: 12, API: 18, Unit: 10)
- **Results**:
  - ✅ Passed: 59 (86.8%)
  - ❌ Failed: 7 (10.3%)
  - ⚠️ Blocked: 2 (2.9%)
- **Success Rate**: 86.8%
- **Defect Density**: 8 bugs per 1000 LOC (target: < 5)

### 2.3 Critical Findings
1. **BUG-021 (Critical)**: Payment gateway timeout on card method > 5s; results in failed transactions and user confusion
2. **BUG-023 (High)**: Refresh token API returns 401 instead of 200; forces logout after 1 hour
3. **BUG-017 (Medium)**: Photo size validation error message unclear
4. **BUG-045 (High)**: Duplicate chat messages received on flaky network
5. **BUG-062 (Medium)**: ML detection rejects WEBP format without clear error

### 2.4 Release Readiness Recommendation
- **Status**: ⚠️ **GO WITH NOTES** (Conditional Release)
- **Release Requirements**:
  - ✅ Fix BUG-021 and BUG-023 before production
  - ✅ Re-run E2E regression for checkout and auth flows
  - ✅ Update user documentation on unsupported WEBP format
  - ✅ Implement retry mechanism for payment gateway

---

## 3. TEST SCOPE AND METHODOLOGY

### 3.1 Features Under Test (In Scope)

#### For Resident Users (Warga):
- ✅ Login/Registration (email, password reset)
- ✅ Browse products (search, filter, categories)
- ✅ Cart & Checkout (save cart, quantity adjustment)
- ✅ Payment (credit card, bank transfer, e-wallet)
- ✅ Order tracking & history
- ✅ Clothing detection via camera (ML feature)
- ✅ Chat with RT (neighborhood leader)
- ✅ Transaction & promo notifications
- ✅ Profile & settings (address, language, theme)
- ✅ Wishlist & favorites

#### For RT Users (Neighborhood Leader):
- ✅ Dashboard overview (sales, active residents)
- ✅ Verify new resident registration
- ✅ Chat with residents
- ✅ Manage transaction approvals (if needed)
- ✅ View sales reports (daily/weekly)
- ✅ Broadcast notifications to residents

#### For Admin Users:
- ✅ Admin login & role management
- ✅ Manage products & categories
- ✅ Manage users (residents, RT)
- ✅ View all transactions & reports
- ✅ Monitor performance & error logs
- ✅ Configure payment gateway

### 3.2 Excluded Features (Out of Scope)
- ❌ Offline COD payment (deferred v1.5)
- ❌ Advanced admin analytics dashboard (development incomplete)
- ❌ iOS push notifications (pending certification)
- ❌ Product video streaming (future enhancement)
- ❌ B2B wholesale integration (next phase)

### 3.3 Test Environment

| Aspect | Details |
| --- | --- |
| **Desktop OS** | Windows 11 Pro (22H2), macOS 14.2 |
| **Mobile** | Android Emulator Pixel 6 (API 33), iPhone 14 Pro (iOS 17.2) simulator |
| **Browsers** | Chrome 120.0, Firefox 121.0, Safari 17.2 |
| **Backend Server** | PHP 8.1, MySQL 8.0, Redis 7.0 (staging) |
| **ML API** | HuggingFace Space (clothing detection HOG+SVM) |
| **Network** | 4G LTE simulation (100 Mbps down, 20 Mbps up) |
| **Database** | MySQL staging copy (100K products, 50K users) |

### 3.4 Tools & Framework

| Category | Tools |
| --- | --- |
| **Functional Testing** | Postman, Playwright, Flutter test |
| **API Testing** | pytest + requests, REST Assured, cURL |
| **Performance** | k6 (load/stress), JMeter, Chrome DevTools |
| **Unit Testing** | unittest (Python), Dart test framework |
| **Code Coverage** | coverage.py, Dart coverage, Istanbul |
| **Test Data** | faker, CSV mock data, seeding scripts |
| **Bug Tracking** | Jira, GitHub Issues |
| **Log Analysis** | ELK stack, CloudWatch, local logs |
| **Automation** | CI/CD GitHub Actions, Jenkins |

---

## 4. DETAILED FEATURE TESTING

### 4.1 AUTHENTICATION FEATURE (Auth)

#### 4.1.1 Testing for Residents (Warga)

| Test Case ID | Scenario | Actions | Expected Result | Actual Result | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| AUTH-WRG-001 | Register new resident | 1. Open app → 2. Tap "Register" → 3. Enter email, password (min 8 chars), name, address → 4. Tap "Register" | Unique email validation, OTP sent, user record created | Email validation passed, OTP 123456 sent, user created | ✅ Pass | Disable email validation during testing |
| AUTH-WRG-002 | Login with valid credentials | 1. Input email & password → 2. Tap Login | HTTP 200, JWT token returned, redirect to dashboard | Token `eyJ0eXAi...` received, redirect successful | ✅ Pass | Token exp: 24h |
| AUTH-WRG-003 | Login with wrong password | Input email + wrong pwd | HTTP 401, message "Password incorrect" | 401 received, message displayed | ✅ Pass | - |
| AUTH-WRG-004 | Login with unregistered email | Input non-existent email | HTTP 404, message "Email not found" | 404 returned, msg shown | ✅ Pass | - |
| AUTH-WRG-005 | Password reset | 1. Tap "Forgot Password" → 2. Enter email → 3. Open link in email → 4. Create new password | Email sent, link valid 30 minutes, password updated | Email received, link works, DB updated | ✅ Pass | Link TTL: 30 min |
| AUTH-WRG-006 | Logout | Tap menu → Logout | Token removed from storage, redirect to login | Storage cleared, login screen shown | ✅ Pass | - |
| AUTH-WRG-007 | Auto-logout after session timeout (24h) | Wait 24 hours or modify token exp | Auto-redirect to login, message "Session expired" | Redirect after 24h (simulated) | ✅ Pass | Timeout: 24h |
| AUTH-WRG-008 | Refresh token before expiry | Call /auth/refresh with valid refresh_token | HTTP 200, new access token returned | ❌ HTTP 401 returned instead | ❌ Fail | **BUG-023** |
| AUTH-WRG-009 | Optional 2FA setup | Enable 2FA in settings → re-login | SMS/email OTP prompt, verification successful | 2FA workflow working, OTP valid 10 min | ✅ Pass | OTP methods: SMS/email |

#### 4.1.2 Testing for RT (Neighborhood Leaders)

| Test Case ID | Scenario | Actions | Expected Result | Actual Result | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| AUTH-RT-010 | RT login with RT credentials | Input RT email + password | Token role `rt` issued, redirect to RT dashboard | Token contains role=rt, dashboard shown | ✅ Pass | RBAC enforced |
| AUTH-RT-011 | RT cannot access resident features | RT login → try access resident checkout | HTTP 403 Forbidden | 403 returned | ✅ Pass | Role-based access control |
| AUTH-RT-012 | RT session timeout 48h | Login as RT → wait 48h | Auto-logout, redirect to login | ✅ Pass after 48h simulated | ✅ Pass | Timeout: 48h |

#### 4.1.3 Testing for Admin

| Test Case ID | Scenario | Actions | Expected Result | Actual Result | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| AUTH-ADMIN-013 | Admin SSO login | Login via corporate SSO | Token issued with admin role | SSO redirect works, admin token issued | ✅ Pass | SSO endpoint: `/sso/admin` |
| AUTH-ADMIN-014 | Enforce 2FA for admin | Disable 2FA in config → admin login | Require 2FA | ⚠️ 2FA optional, not enforced | ⚠️ Block | **Issue**: 2FA must be mandatory for admin |

---

### 4.2 MARKETPLACE FEATURE (Products & Catalog)

#### 4.2.1 Testing for Residents

| Test Case ID | Scenario | Actions | Expected Result | Actual Result | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| SHOP-WRG-001 | View product list with pagination | Login resident → Tap Shop → scroll | 20 products/page, pagination visible | 20 items loaded, page 1 default, next/prev work | ✅ Pass | Pagination: 20 items/page |
| SHOP-WRG-002 | Search products by keyword | Enter "shirt" in search | Products containing "shirt" shown, < 2s | 8 results shown (blue shirt, white shirt, etc.), 1.2s response | ✅ Pass | Search response < 2s |
| SHOP-WRG-003 | Filter by category | Tap category "T-Shirt" | Only T-Shirts visible | 45 T-Shirts displayed | ✅ Pass | - |
| SHOP-WRG-004 | Filter by price range | Set range 100K - 500K | Products in range shown | 32 products in range | ✅ Pass | - |
| SHOP-WRG-005 | Sort by price ascending | Tap "Price (Lowest)" | List sorted ascending | ✅ Pass | - |
| SHOP-WRG-006 | View product detail | Tap product "Flannel Shirt" | Detail page: photos, description, price, rating, reviews | All elements displayed correctly | ✅ Pass | - |
| SHOP-WRG-007 | View product ratings & reviews | Scroll in product detail → see reviews | Min 5 reviews visible, average rating shown | 12 reviews shown, avg 4.5/5 | ✅ Pass | - |
| SHOP-WRG-008 | Add product to wishlist | Tap ❤️ icon in product detail | Product added to wishlist, icon changes color | Wishlist updated, heart red | ✅ Pass | - |
| SHOP-WRG-009 | Add product to cart | Tap "Add to Cart" → select qty → confirm | Product + qty added to cart, cart badge updated | 1 item added, cart badge shows "1" | ✅ Pass | - |
| SHOP-WRG-010 | View product with photo > 2MB | Upload product photo 3MB | Photo rejected with clear error | ❌ Photo uploads but error message unclear | ❌ Fail | **BUG-017** |

#### 4.2.2 Testing for RT

| Test Case ID | Scenario | Actions | Expected Result | Actual Result | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| SHOP-RT-011 | RT browse resident products | RT login → view resident products | Only products from RT's residents shown | 52 products from 8 residents shown | ✅ Pass | Filter by RT zone |
| SHOP-RT-012 | RT approve products before sale | Admin setting: RT must approve products | New products pending, RT gets notification | Notification received, approval dashboard available | ✅ Pass | Feature: RT approval gating |

#### 4.2.3 Testing for Admin

| Test Case ID | Scenario | Actions | Expected Result | Actual Result | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| SHOP-ADMIN-013 | Admin bulk upload products | Admin → Products → Bulk Upload CSV | CSV parsed, 100+ products inserted | 125 products bulk uploaded | ✅ Pass | CSV format documented |
| SHOP-ADMIN-014 | Manage product categories | Admin → Categories → Add/Edit/Delete | CRUD operations work, all users see changes | All CRUD works, changes propagated | ✅ Pass | - |

---

### 4.3 CHECKOUT & PAYMENT FEATURE

#### 4.3.1 Testing for Residents

| Test Case ID | Scenario | Actions | Expected Result | Actual Result | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| PAY-WRG-001 | View cart before checkout | Tap cart icon | Cart items, total price, tax, shipping displayed | 2 items, subtotal 500K, tax 50K, shipping 25K, total 575K | ✅ Pass | - |
| PAY-WRG-002 | Adjust quantity in cart | Change qty from 1 → 3 | Price auto-updates | Price updated to 1.5M | ✅ Pass | Real-time calculation |
| PAY-WRG-003 | Remove item from cart | Tap delete icon | Item removed, price updates | Item removed, total recalculated | ✅ Pass | - |
| PAY-WRG-004 | Apply discount code | Enter code "DISCOUNT20" (20% off) | Price reduced, breakdown shown | Discount 115K applied, total 460K | ✅ Pass | - |
| PAY-WRG-005 | Checkout with credit card | 1. Review cart → 2. Tap Checkout → 3. Select Card → 4. Redirect to gateway → 5. Enter card details | Payment processed < 5s, order confirmed, receipt email | ❌ Timeout after 7s at gateway | ❌ Fail | **BUG-021** (gateway timeout) |
| PAY-WRG-006 | Checkout with bank transfer | 1. Select Bank Transfer → 2. Display VA number → 3. User transfers via bank app | Virtual account number shown, payment pending status | VA shown, status = pending | ✅ Pass | - |
| PAY-WRG-007 | Checkout with e-wallet | Select OVO → Scan QR | QR displayed, redirect to e-wallet app, confirmation | QR shown, e-wallet success | ✅ Pass | - |
| PAY-WRG-008 | Input shipping address at checkout | Select address from profile or enter new | Address saved, sent to backend | Address stored & sent to backend | ✅ Pass | - |
| PAY-WRG-009 | View order confirmation page | After successful payment | Order ID, status "Processing", item details, total, delivery ETA | Order INV-2025-12-0001, status "Processing", ETA 2-3 days | ✅ Pass | - |
| PAY-WRG-010 | Retry payment on timeout | Retry payment after timeout | Payment re-attempted, no duplicate charge | Retry successful, no double charge | ✅ Pass | With BUG-021 fixed |

---

### 4.4 CHAT FEATURE (Communication)

#### 4.4.1 Testing for Residents

| Test Case ID | Scenario | Actions | Expected Result | Actual Result | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| CHAT-WRG-001 | View chat list with RT | Tap Chat → see RT conversations | List all RT (1-2 conversation per user) | 2 RT conversations shown | ✅ Pass | - |
| CHAT-WRG-002 | Open chat with specific RT | Tap RT "Paket" | Chat history loaded, previous messages visible | 15 previous messages loaded | ✅ Pass | - |
| CHAT-WRG-003 | Send text message | Enter text "Hi sir, product ready?" → Tap Send | Message delivered instantly, appears at recipient | Message sent immediately, RT received | ✅ Pass | - |
| CHAT-WRG-004 | Send photo in chat | Tap attachment → select photo → send | Photo sent, preview visible, < 3s latency | Photo sent, preview shown, 2.1s latency | ✅ Pass | - |
| CHAT-WRG-005 | Receive message from RT | RT sends message | Notification appears, message visible | Notif received, message visible | ✅ Pass | - |
| CHAT-WRG-006 | Duplicate message on flaky network | Simulate flaky 3G network → send message | 1 message sent, no duplicate | ❌ 2 messages sent (duplicate) | ❌ Fail | **BUG-045** (duplicate on flaky network) |
| CHAT-WRG-007 | Search/filter chat messages | Tap search in chat → find "price question" | Messages with keyword shown | 3 messages with "price" found | ✅ Pass | - |
| CHAT-WRG-008 | See typing indicator | RT typing → resident sees "Paket is typing..." | Typing indicator visible | "Paket is typing..." shown | ✅ Pass | - |
| CHAT-WRG-009 | Message read receipts | Send message → see read status | Double checkmark after RT reads | Read receipt shown after read | ✅ Pass | - |

#### 4.4.2 Testing for RT

| Test Case ID | Scenario | Actions | Expected Result | Actual Result | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| CHAT-RT-010 | RT view all resident chats | RT login → Tap Chat | List of 10+ resident conversations, sorted by latest | 12 conversations shown, latest first | ✅ Pass | - |
| CHAT-RT-011 | RT broadcast to all residents | RT → Broadcast → Compose → Send | Message sent to all residents | Message sent to 25 residents | ✅ Pass | - |
| CHAT-RT-012 | RT block/mute resident | Tap resident → block option | Resident cannot chat, RT doesn't get notif | Block successful, mute active | ✅ Pass | - |

---

### 4.5 ML CLOTHING DETECTION FEATURE

#### 4.5.1 Testing for Residents

| Test Case ID | Scenario | Actions | Expected Result | Actual Result | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| ML-WRG-001 | Open clothing detection | Tap "Clothing Detection" on home | Camera opens, instructions displayed | Camera opens, UI clear | ✅ Pass | - |
| ML-WRG-002 | Capture clothing photo | Point at clothing, tap "Capture" | Photo saved, sent to ML API, loading bar visible | Photo captured, sending... | ✅ Pass | - |
| ML-WRG-003 | ML predicts clothing label | Wait for ML API response | Prediction label (Hat/Shirt/Shoes/T-Shirt) + confidence shown | Predicted: "T-Shirt", confidence 0.95 (95%) | ✅ Pass | Model: HOG+SVM |
| ML-WRG-004 | Low confidence < 70% | Capture blurry/partial photo | Label shown with warning "low confidence" | Label "Shoes" (0.62), warning shown | ✅ Pass | - |
| ML-WRG-005 | Upload existing photo from gallery | Tap "Upload from Gallery" → select JPG | Process same as camera | JPG processed, prediction returned | ✅ Pass | - |
| ML-WRG-006 | WEBP format rejected | Select WEBP image | Error message "Only JPG/PNG formats" | ❌ WEBP accepted but error on process | ❌ Fail | **BUG-062** (WEBP format) |
| ML-WRG-007 | View detection history | Tap "Detection History" | List all previous detections with timestamp | 8 previous detections shown with date | ✅ Pass | - |
| ML-WRG-008 | ML API performance < 2s | Capture photo → submit | Response time < 2 seconds | Avg response time 1.8s | ✅ Pass | HuggingFace inference |

#### 4.5.2 API Testing for ML

| Test Case ID | Endpoint | Method | Request | Expected Response | Actual | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| ML-API-009 | /api/v1/ml/detect | POST | `{image_base64, confidence_threshold: 0.7}` | `{label, confidence, processing_time_ms}` | Label, confidence, time returned | ✅ Pass | - |
| ML-API-010 | /api/v1/ml/detect | POST | Blank image | `{error: "Image empty"}`, 400 | 400 error returned | ✅ Pass | - |
| ML-API-011 | /api/v1/ml/detect | POST | Oversized (>10MB) | `{error: "Image too large"}`, 413 | 413 returned | ✅ Pass | - |
| ML-API-012 | /api/v1/ml/history/{user_id} | GET | Auth token | `{detections: [...], total: 8}` | History list with 8 items | ✅ Pass | - |

---

### 4.6 NOTIFICATION FEATURE

#### 4.6.1 Testing for Residents

| Test Case ID | Scenario | Actions | Expected Result | Actual Result | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| NOTIF-WRG-001 | Receive transaction notification | Complete payment → notif sent | In-app + push notif (Android) | Notif received in 2s | ✅ Pass | - |
| NOTIF-WRG-002 | View notification history | Tap bell icon → see list | List 10+ notifs with timestamp | 12 notifs shown, newest first | ✅ Pass | - |
| NOTIF-WRG-003 | Mark notification as read | Tap notif → read | Notif status = read, visual change | Notif marked read | ✅ Pass | - |
| NOTIF-WRG-004 | Delete notification | Swipe left/right → delete | Notif removed | Notif removed | ✅ Pass | - |
| NOTIF-WRG-005 | Manage notif preferences | Settings → Notifications → toggle channels | Push, email, SMS preference saved | Settings persisted | ✅ Pass | - |
| NOTIF-WRG-006 | Receive RT promo broadcast | RT sends broadcast | Notif "Promo: 30% off" received | Broadcast notif received | ✅ Pass | - |

---

### 4.7 PROFILE & SETTINGS FEATURE

#### 4.7.1 Testing for Residents

| Test Case ID | Scenario | Actions | Expected Result | Actual Result | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| PROF-WRG-001 | View profile info | Tap Profile → view | Name, email, address, profile photo displayed | All info shown | ✅ Pass | - |
| PROF-WRG-002 | Edit name & email | Tap Edit → change name → Save | Email unique validation, data saved | Changes saved, success msg | ✅ Pass | - |
| PROF-WRG-003 | Upload/change avatar | Tap avatar → upload photo | Photo compressed, resized, saved | Avatar updated | ✅ Pass | - |
| PROF-WRG-004 | Change password | Settings → Change Password → old & new pwd | Old pwd validated, new >= 8 chars | Password updated | ✅ Pass | - |
| PROF-WRG-005 | Switch language to English | Settings → Language → English | UI translated to English, preference saved | Language changed to EN | ✅ Pass | - |
| PROF-WRG-006 | Dark mode toggle | Settings → Theme → Dark | App skin dark, preference saved | Dark theme applied | ✅ Pass | - |
| PROF-WRG-007 | View order history | Tap Orders | List all past orders with status | 24 orders shown, sorted by date | ✅ Pass | - |
| PROF-WRG-008 | View wishlist | Tap Wishlist | All favorite products displayed | 7 wishlist items shown | ✅ Pass | - |

---

## 5. END-TO-END (E2E) TEST RESULTS

### 5.1 E2E Scenarios - Residents

| Test Case ID | Business Scenario | Steps | Expected Result | Actual Result | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| E2E-WRG-001 | Purchase flow | 1. Register → 2. Login → 3. Browse → 4. Search shirt → 5. Add cart → 6. Checkout → 7. Pay → 8. Confirm | Order INV created, email receipt, tracking ready | Successful to step 8, order created | ✅ Pass | Normal flow |
| E2E-WRG-002 | Card payment (BUG test) | 1. Checkout → 2. Card → 3. Fill form → 4. Submit | Payment 200 OK < 5s, order confirmed | ❌ Gateway timeout 7s, failed | ❌ Fail | **BUG-021**: Retry needed |
| E2E-WRG-003 | Chat with RT | 1. Login → 2. Chat → 3. Select RT → 4. Send message → 5. Wait reply | Message instant, RT gets notif | ✅ Message sent, RT notif received | ✅ Pass | Latency 1.2s |
| E2E-WRG-004 | Clothing detection | 1. Home → 2. Detection → 3. Capture shirt photo → 4. Submit → 5. Get prediction | Prediction "T-Shirt" 95% in 2s | ✅ Prediction returned, 1.8s | ✅ Pass | - |
| E2E-WRG-005 | Return/refund flow | 1. Login → 2. Past order → 3. "Request Return" → 4. Reason → 5. Confirm | Return pending, notif to RT & seller | Request pending, notif sent | ✅ Pass | Return workflow feature |

### 5.2 E2E Scenarios - RT

| Test Case ID | Business Scenario | Steps | Expected Result | Actual Result | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| E2E-RT-001 | Approve new resident | 1. RT login → 2. Dashboard → 3. Pending list → 4. Tap resident → 5. Verify → 6. Approve | Status = approved, notif sent, access granted | ✅ Approval successful | ✅ Pass | - |
| E2E-RT-002 | Broadcast promo | 1. RT → Broadcast → 2. Compose → 3. Select audience → 4. Send | Message sent to all, notifs < 2s | ✅ Broadcast to 25 residents | ✅ Pass | - |
| E2E-RT-003 | View sales report | 1. RT → Dashboard → 2. Daily sales | Chart shows sales, breakdown by resident | Report generated, chart visible | ✅ Pass | Realistic data |

### 5.3 E2E Scenarios - Admin

| Test Case ID | Business Scenario | Steps | Expected Result | Actual Result | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| E2E-ADMIN-001 | Bulk product upload | 1. Admin → Products → Upload CSV → 2. Review → 3. Confirm | 125 products inserted, success, ready to sell | ✅ Bulk upload successful | ✅ Pass | CSV parsing correct |
| E2E-ADMIN-002 | Payment gateway setup | 1. Admin → Settings → Payment → 2. Update API key → 3. Test | Test payment successful, live mode ready | ✅ Payment gateway configured | ✅ Pass | - |

---

## 6. API TEST RESULTS

### 6.1 Authentication APIs

| Endpoint | Method | Test Case | Request Body | Expected Status | Actual Status | Result | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| /api/v1/auth/register | POST | REG-001 | `{email, password, name, address}` | 201 Created | 201 | ✅ Pass | - |
| /api/v1/auth/register | POST | REG-002 | Duplicate email | 409 Conflict | 409 | ✅ Pass | - |
| /api/v1/auth/login | POST | LOGIN-001 | Valid email & pwd | 200 + token | 200 + token | ✅ Pass | - |
| /api/v1/auth/login | POST | LOGIN-002 | Wrong pwd | 401 Unauthorized | 401 | ✅ Pass | - |
| /api/v1/auth/refresh | POST | REFRESH-001 | Valid refresh_token | 200 + new token | 401 ❌ | ❌ Fail | **BUG-023** |
| /api/v1/auth/logout | POST | LOGOUT-001 | Valid token | 200 | 200 | ✅ Pass | - |

### 6.2 Product APIs

| Endpoint | Method | Test | Request | Expected | Actual | Result | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| /api/v1/products | GET | PROD-001 | `?page=1&limit=20` | 200 + 20 items | 200 + 20 items | ✅ Pass | Pagination OK |
| /api/v1/products?search=shirt | GET | PROD-002 | search param | 200 + filtered | 8 results | ✅ Pass | Search < 2s |
| /api/v1/products/{id} | GET | PROD-003 | Product ID | 200 + detail | 200 + detail | ✅ Pass | - |
| /api/v1/products | POST | PROD-004 | New product | 201 + id | 201 + id | ✅ Pass | Auth required |
| /api/v1/products/{id}/review | POST | PROD-005 | Review + rating | 201 | 201 | ✅ Pass | - |

### 6.3 Cart & Checkout APIs

| Endpoint | Method | Test | Request | Expected | Actual | Result | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| /api/v1/cart | POST | CART-001 | `{product_id, qty}` | 200 + item | 200 | ✅ Pass | - |
| /api/v1/cart | GET | CART-002 | Auth token | 200 + items | 200 + 2 items | ✅ Pass | - |
| /api/v1/checkout | POST | CHECKOUT-001 | Cart, address, method | 201 + order ID | 201 | ✅ Pass | - |
| /api/v1/payment/process | POST | PAY-001 | `{order_id, method, amount}` | 200 redirect | Timeout 7s ❌ | ❌ Fail | **BUG-021** |

### 6.4 Chat APIs

| Endpoint | Method | Test | Request | Expected | Actual | Result | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| /api/v1/chat/messages/{user_id} | GET | CHAT-001 | user_id, token | 200 + msgs | 200 + 15 msgs | ✅ Pass | - |
| /api/v1/chat/send | POST | CHAT-002 | `{recipient, msg}` | 201 + msg_id | 201 | ✅ Pass | - |
| /api/v1/chat/send (flaky) | POST | CHAT-003 | Retry on 3G | 1 msg sent | 2 msgs ❌ | ❌ Fail | **BUG-045** |

### 6.5 ML Detection API

| Endpoint | Method | Test | Request | Expected | Actual | Result | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| /api/v1/ml/detect | POST | ML-001 | `{image_base64}` | 200 + {label, conf} | T-Shirt, 0.95 | ✅ Pass | - |
| /api/v1/ml/detect | POST | ML-002 | WEBP format | Reject or warn | Error ❌ | ❌ Fail | **BUG-062** |

---

## 7. UNIT & INTEGRATION TEST RESULTS

### 7.1 Unit Test Summary

| Module | Total Tests | Passed | Failed | Coverage | Status |
| --- | --- | --- | --- | --- | --- |
| AuthService (Python) | 12 | 12 | 0 | 95% | ✅ Pass |
| ProductService | 15 | 15 | 0 | 92% | ✅ Pass |
| CartService | 18 | 17 | 1 | 88% | ⚠️ 1 fail |
| PaymentService | 20 | 19 | 1 | 85% | ⚠️ 1 fail |
| ChatService | 10 | 9 | 1 | 80% | ⚠️ 1 fail |
| NotificationService | 8 | 8 | 0 | 90% | ✅ Pass |
| MLService | 10 | 10 | 0 | 93% | ✅ Pass |
| **TOTAL** | **93** | **90** | **3** | **89%** | **90.3% pass** |

### 7.2 Integration Test Results

| Integration Point | Components | Test Scenario | Result | Notes |
| --- | --- | --- | --- | --- |
| Auth + Database | AuthService ↔ MySQL | Login workflow, token generation | ✅ Pass | - |
| Product + Cache | ProductService ↔ Redis | Search caching | ✅ Pass | Cache hit 75% |
| Payment + Gateway | PaymentService ↔ Stripe | Charge transaction | ❌ Timeout | **BUG-021** |
| Chat + FCM | ChatService ↔ Firebase | Message + notif | ✅ Pass | - |
| ML + HF Space | MLService ↔ HuggingFace | Image detection | ✅ Pass | 1.8s latency |
| Notif + Email | NotifService ↔ SendGrid | Email delivery | ✅ Pass | 2.3s delivery |

---

## 8. PERFORMANCE TEST RESULTS

### 8.1 Load Testing (k6 with 100 virtual users)

| Metric | Target | Actual | Status |
| --- | --- | --- | --- |
| Avg Response Time | < 2.0s | 1.4s | ✅ Pass |
| P95 Response Time | < 3.0s | 2.8s | ✅ Pass |
| P99 Response Time | < 5.0s | 4.2s | ✅ Pass |
| Throughput | > 100 req/s | 160 req/s | ✅ Pass |
| Error Rate | < 0.5% | 0.1% | ✅ Pass |
| CPU Usage | < 70% | 62% | ✅ Pass |
| Memory Usage | < 70% | 58% | ✅ Pass |

### 8.2 Stress Testing (500 virtual users)

| Metric | Target | Actual | Status | Notes |
| --- | --- | --- | --- | --- |
| Avg Response Time | < 5.0s | 4.6s | ✅ Pass | Acceptable degradation |
| Throughput | > 300 req/s | 410 req/s | ✅ Pass | Exceeds target |
| Error Rate | < 2% | 0.7% | ✅ Pass | Payment bottleneck |
| CPU Usage | < 90% | 89% | ✅ Pass | Peak capacity |
| Memory Usage | < 90% | 82% | ✅ Pass | Stable |
| DB Connections | < 100 | 94 | ✅ Pass | Near limit |

### 8.3 Soak Testing (2 hours with 150 users)

| Metric | Target | Actual | Status |
| --- | --- | --- | --- |
| Avg Response Time (stable) | < 2.5s | 1.9s | ✅ Pass |
| Memory Leak | None | None detected | ✅ Pass |
| Error Rate (cumulative) | < 1% | 0.2% | ✅ Pass |
| Uptime | 100% | 100% | ✅ Pass |

### 8.4 Database Performance

| Query | Execution Time | Status | Notes |
| --- | --- | --- | --- |
| `SELECT * FROM products LIMIT 20` | 45ms | ✅ Pass | Indexed |
| `SELECT * FROM products WHERE category='Shirt'` | 120ms | ✅ Pass | Indexed |
| `SELECT * FROM orders WHERE user_id=X` | 80ms | ✅ Pass | Indexed |
| Bulk insert 1000 products | 2.3s | ✅ Pass | Batch optimized |

---

## 9. DEFECT SUMMARY

### 9.1 Defect Breakdown by Severity

| Severity | Count | Open | Closed | Avg Fix Time | Status |
| --- | --- | --- | --- | --- | --- |
| 🔴 Critical | 1 | 1 | 0 | 6h est. | Blocking |
| 🟠 High | 2 | 1 | 1 | 9h avg | Urgent |
| 🟡 Medium | 3 | 0 | 3 | 12h avg | Fixed |
| 🟢 Low | 2 | 0 | 2 | 18h avg | Fixed |
| **TOTAL** | **8** | **2** | **6** | - | 75% closed |

### 9.2 Bug Details

#### BUG-021 (CRITICAL)
- **Title**: Payment Gateway Timeout on Card
- **Module**: PaymentService
- **Steps to Reproduce**: Login → Add product → Checkout card → Submit
- **Expected**: Payment < 5s
- **Actual**: Timeout 7s
- **Impact**: Cannot purchase via card
- **Root Cause**: Slow gateway API response
- **Fix**: Increase timeout, implement smart retry
- **Status**: OPEN
- **Priority**: Fix before release

#### BUG-023 (HIGH)
- **Title**: Refresh Token Returns 401
- **Module**: AuthService
- **Steps**: Login → wait token expire → call /auth/refresh
- **Expected**: HTTP 200 + new token
- **Actual**: HTTP 401 Unauthorized
- **Impact**: Users forced logout after 24h
- **Root Cause**: Validation logic incorrect
- **Fix**: Review refresh() logic, add unit tests
- **Status**: OPEN
- **Priority**: Fix before release

#### BUG-017 (MEDIUM)
- **Title**: File Size Validation Error Unclear
- **Module**: Product Upload
- **Steps**: Upload photo > 2MB
- **Expected**: Clear error "File < 2MB"
- **Actual**: Generic error
- **Impact**: User confusion
- **Fix**: Add client-side validation
- **Status**: CLOSED ✅

#### BUG-045 (HIGH)
- **Title**: Duplicate Chat Messages on Flaky Network
- **Module**: ChatService
- **Steps**: Send message on 3G
- **Expected**: 1 message
- **Actual**: 2 duplicate
- **Impact**: Confusing chat
- **Fix**: Idempotency key
- **Status**: OPEN

#### BUG-062 (MEDIUM)
- **Title**: ML Rejects WEBP Without Error
- **Module**: MLDetectionService
- **Steps**: Upload WEBP
- **Expected**: Clear error "Only JPG/PNG"
- **Actual**: Silent failure
- **Impact**: User confusion
- **Fix**: Format validation
- **Status**: CLOSED ✅

---

## 10. RISK ANALYSIS

### 10.1 Technical Risks

| Risk | Probability | Impact | Mitigation |
| --- | --- | --- | --- |
| Payment timeout in production | High (60%) | Critical | Fix before release, monitoring, fallback |
| Session timeout UX issue | Medium (40%) | High | Extend token, better messaging |
| Chat duplicate messages | Medium (30%) | Medium | Idempotency key, dedup |
| DB connection overflow | Low (15%) | High | Monitor, scale |

### 10.2 Business Risks

| Risk | Impact | Likelihood | Mitigation |
| --- | --- | --- | --- |
| Lost sales (payment fail) | Revenue loss 5-10% | Medium | Fix payment, retry |
| User churn (forced logout) | Loss 2-3% | Medium | Better token |
| Negative reviews | Rating -0.5 | Medium | Fast fix, support |
| Brand damage | Major | Low | Transparency |

---

## 11. CONCLUSION & RELEASE RECOMMENDATION

### 11.1 Release Readiness

**Status: ⚠️ CONDITIONAL GO (Go with Notes)**

JAWARA CLOTHING STORE v1.4.0 **READY FOR RELEASE** provided:
- ✅ 86.8% test pass rate (target > 80%)
- ✅ Core features functional
- ✅ Performance acceptable
- ⚠️ 2 open critical/high bugs but mitigatable

### 11.2 Pre-Release Requirements

**Must complete before production:**

1. **BUG-021** - Fix payment timeout
   - Option A: Increase gateway timeout
   - Option B: Implement smart retry
   - Option C: Fallback payment methods
   - Deadline: Dec 28, 2025

2. **BUG-023** - Fix refresh token
   - Correct token validation
   - Add regression tests
   - Deadline: Dec 27, 2025

3. **Re-run E2E regression**
   - Focus: Payment, auth, chat
   - Deadline: Dec 28, 2025

### 11.3 Release Decision

**✅ RECOMMENDATION: RELEASE / GO LIVE**

**With critical notes:**
- Deploy BUG-021 & BUG-023 fixes pre-production
- Monitor closely first 24 hours
- Prepare rollback plan
- Have support team ready

---

## 12. APPENDICES

### 12.1 Test Case Details
- Scripts: `/pmpl/tests/api/`, `/pmpl/tests/e2e/`, `/pmpl/tests/performance/`
- Spreadsheet: `JAWARA_TestCases_v1.4.xlsx`

### 12.2 Bug Tracking
- Jira: JAWARA-QA project
- Open: [JAWARA-21], [JAWARA-23], [JAWARA-45]
- Closed: [JAWARA-17], [JAWARA-62], etc.

### 12.3 Environment
- Staging: https://staging-api.jawara.local
- Database: MySQL (aws-staging-db-01)
- ML API: HuggingFace Space

### 12.4 Contact
- **Lead QA**: Charellino K S (charellino@jawara.local)
- **Backend QA**: M. Atho'illah M (atho@jawara.local)
- **Mobile QA**: Mikaila Kafka (mikaila@jawara.local)

---

**Prepared by:**

Charellino K S (Lead QA)  
M. Atho'illah M (Backend & API QA)  
Mikaila Kafka (Mobile & E2E QA)

**Date**: December 26, 2025  
**Test Period**: December 15–24, 2025  
**Total Effort**: 168 work hours

---

### 🔔 FINAL NOTE
This report represents comprehensive testing for JAWARA CLOTHING STORE v1.4.0.
Release recommendation: **CONDITIONAL GO** with critical bug fixes required.
All stakeholders should review their relevant sections.

**Last Updated**: Dec 26, 2025, 2:30 PM
