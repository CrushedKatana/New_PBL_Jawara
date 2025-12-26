# SOFTWARE TESTING REPORT (PMPL)

## 1. PROJECT GENERAL INFORMATION
| Item | Details |
| --- | --- |
| Application Name | JAWARA CLOTHING STORE |
| App Version | 1.4.0 (RC) |
| Test Period | 15–24 December 2025 |
| Test Team | Charellino K S; M. Atho'illah M; Mikaila Kafka |
| Report Completion Date | 26 December 2025 |

## 2. EXECUTIVE SUMMARY
- Goal: verify core functions (auth, marketplace, chat, notifications, clothing detection) and performance stability.
- Scope: Functional, E2E, API, Unit & Integration, Performance.
- Metrics summary: total 24 test cases (functional+E2E+API); 21 Pass, 3 Fail, 0 Blocked ⇒ Success rate 87.5%.
- Critical findings: 1) Payment gateway timeout on E2E checkout path; 2) Refresh token expires too early on `POST /auth/refresh`.
- Release recommendation: Go, but fix payment timeout and refresh token before production.

## 3. TEST SCOPE AND METHODOLOGY
- Included features: login/registration, product management, cart & checkout, RT/warga chat, notifications, clothing detection (HOG+SVM), profile & settings.
- Excluded: offline COD payments, advanced admin analytics dashboard (not ready), iOS push notifications (deferred).
- Environment: Windows 11, Android Emulator Pixel 6 (API 33), Chrome 120, PHP + MySQL backend (staging), ML API on HuggingFace Space.
- Tools: pytest+requests (API), Playwright (web E2E), Flutter integration test (mobile smoke), k6 (performance), coverage.py (unit), dummy CSV test data.

## 4. FUNCTIONAL TEST RESULTS
### 4.1. FUNCTIONAL TESTING
| Module/Feature | Test Case ID | Description | Result | Notes/Bug ID |
| --- | --- | --- | --- | --- |
| Login | FUNC-LOG-001 | Login with valid credentials | Pass | - |
| Login | FUNC-LOG-002 | Login with wrong password | Pass | - |
| Product | FUNC-PROD-003 | Add product with all required fields | Pass | - |
| Product | FUNC-PROD-004 | Upload product photo > 2MB | Fail | BUG-017 (size validation) |
| Notifications | FUNC-NOT-005 | Toggle notifications and save preferences | Pass | - |
| Clothing Detection | FUNC-ML-006 | Send photo and get predicted label | Pass | - |
| Chat | FUNC-CHAT-007 | Send text RT ↔ warga | Pass | - |
| Payment | FUNC-PAY-008 | Checkout with card | Pass | - |
| Payment | FUNC-PAY-009 | Checkout with bank transfer | Pass | - |
| Profile | FUNC-PROF-010 | Change avatar and save | Pass | - |
| Settings | FUNC-SET-011 | Switch language to EN | Pass | - |
| Settings | FUNC-SET-012 | Toggle theme (dark/light) | Pass | - |

Summary: Total 12, Pass 11, Fail 1, Success Rate 91.7%.

### 4.2. END-TO-END (E2E) TESTING
| Scenario/Business Flow | Test Case ID | Flow Description | Result | Notes/Bug ID |
| --- | --- | --- | --- | --- |
| Order to Payment | E2E-ORD-001 | Login → pick product → checkout → pay → confirm | Fail | BUG-021 (gateway timeout) |
| RT Approval | E2E-RT-002 | Login as RT → verify new resident → approve | Pass | - |
| Notifications | E2E-NOT-003 | Trigger transaction event → send push → visible in app | Pass | - |
| Chat Lifeline | E2E-CHAT-004 | Login → open chat → send & receive messages | Pass | - |
| ML Detection Flow | E2E-ML-005 | Capture photo → send to ML API → show label & score | Pass | - |

Summary: Total 5, Pass 4, Fail 1, Success Rate 80%.

### 4.3. API TESTING
| API Endpoint | Method | Test Case ID | Scenario | Response Validation | Result | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| /api/v1/login | POST | API-LOG-001 | Valid credentials | 200, token present | Pass | - |
| /api/v1/login | POST | API-LOG-002 | Wrong password | 401, error message | Pass | - |
| /api/v1/products | GET | API-PROD-003 | Public product list | 200, schema OK | Pass | - |
| /api/v1/products | POST | API-PROD-004 | Add product (auth) | 201, id returned | Pass | - |
| /api/v1/chat/{id}/send | POST | API-CHAT-005 | Send message resident → RT | 200, message_id | Pass | - |
| /api/v1/ml/detect | POST | API-ML-006 | Upload clothing photo | 200, label+score | Pass | - |
| /api/v1/auth/refresh | POST | API-AUTH-007 | Refresh expired token | 401 (expected 200) | Fail | BUG-023 |

Summary: Total 7, Pass 6, Fail 1, Success Rate 85.7%.

### 4.4. UNIT & INTEGRATION TESTING
| Component/Unit | Integration Scope | Code Coverage | Result | Notes |
| --- | --- | --- | --- | --- |
| AuthService | TokenProvider integration | 92% | Pass | All auth cases passed |
| ProductService | Cache & API integration | 88% | Pass | Cache hit 70% |
| NotificationService | FCM integration | 81% | Pass | Need extra mock for iOS |
| MLDetectionService | HF API integration | 85% | Pass | Latency stable < 1.2s |

Summary: Total Unit Tests 120, Passed 118, Avg Coverage 87%, Integration Tests Passed 14 of 15.

## 5. NON-FUNCTIONAL TEST RESULTS
### 5.1. PERFORMANCE TESTING
| Load Scenario | Virtual Users | Avg Response Time (target) | Throughput (req/sec) | Error Rate | CPU/Memory Usage | Result vs Target |
| --- | --- | --- | --- | --- | --- | --- |
| Load (Normal) | 100 | 1.4s (<2s) | 160 | 0.1% | CPU 62% / Mem 58% | Meets |
| Stress | 500 | 4.6s (<5s) | 410 | 0.7% | CPU 89% / Mem 82% | Warning (error rate) |
| Soak (2h) | 150 | 1.9s (<2.5s) | 170 | 0.2% | CPU 68% / Mem 65% | Meets |

Analysis: Bottleneck at payment gateway under stress (timeouts). Optimization: add exponential retry, increase checkout DB pool, enable CDN for product images.

## 6. DEFECT SUMMARY
| Severity | Count | Status (Open/Closed) | Avg Fix Time |
| --- | --- | --- | --- |
| Critical | 1 | Open:1 / Closed:0 | 6h |
| High | 2 | Open:1 / Closed:1 | 9h |
| Medium | 3 | Open:0 / Closed:3 | 12h |
| Low | 2 | Open:0 / Closed:2 | 18h |
| TOTAL | 8 | Open:2 / Closed:6 | - |

## 7. RISK ANALYSIS
- Release risks: payment failures (timeout) can block card transactions; refresh token failure causes sudden logout.
- Impact: lost transactions and user frustration when session expires.
- Workaround: fallback to bank transfer/VA; force re-login when refresh fails and show clear message.

## 8. CONCLUSION & RECOMMENDATION
- Readiness: release is acceptable after fixing BUG-021 (payment timeout) and BUG-023 (refresh token) and rerunning a focused regression.
- Recommendation: RELEASE WITH NOTES; deliver hotfix before go-live.
- Follow-up: re-test E2E checkout, refresh token API, and rerun stress test on gateway.

## 9. APPENDIX
- Detailed test cases & scripts: see `tests/` in this folder.
- Defect log: see BUG-017, BUG-021, BUG-023 in the internal tracker.
- Export to PDF: print to PDF via Markdown viewer or run `pandoc README_EN.md -o SOFTWARE_TEST_REPORT.pdf`.

---
Prepared by,

Charellino K S (Lead QA)
M. Atho'illah M
Mikaila Kafka
