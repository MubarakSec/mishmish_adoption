# 🐱 Mishmish — مشمش
### تطبيق تبني القطط (Kitten Adoption App)

> **مشروع مادة تطبيقات الموبايل — د. دينا الموتكلك**  
> تطبيق Flutter متكامل يعتمد على خادم Laravel REST API وقاعدة بيانات MySQL، بواجهة عربية احترافية (RTL) وتصميم عصري متناسق.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Laravel](https://img.shields.io/badge/Laravel-13.x-FF2D20?logo=laravel)](https://laravel.com)
[![MySQL](https://img.shields.io/badge/Database-MySQL-4479A1?logo=mysql)](https://mysql.com)
[![Tests](https://img.shields.io/badge/Tests-Passing-success)](https://github.com)
[![Lints](https://img.shields.io/badge/Flutter_Analyze-Clean-success)](https://flutter.dev)

---

## 📋 جدول مطابقة متطلبات المشروع النهائي

| # | المتطلب في وثيقة المشروع | التفاصيل التقنية في المشروع | الحالة |
|:---|:---|:---|:---:|
| 1 | **خادم الـ Backend** | Laravel REST API مع معالجة طلبات JSON و Validation | ✅ منجز |
| 2 | **قاعدة البيانات** | MySQL مع Migrations و Seeders لـ 12 قطة ومستخدم تجريبي | ✅ منجز |
| 3 | **حزم الـ Frontend الإلزامية** | `http`, `shared_preferences`, `flutter_launcher_icons` | ✅ منجز |
| 4 | **أيقونة التطبيق** | مخصصة ومولدة لجميع مقاسات أندرويد عبر `flutter_launcher_icons` | ✅ منجز |
| 5 | **شاشة البداية (Splash Screen)** | شعار التطبيق وفحص ثلاث حالات: Onboarding ← Login ← Home | ✅ منجز |
| 6 | **شاشات التعريف (Onboarding)** | 3 شاشات تعريفية، حفظ الحالة في `SharedPreferences`، زر "ابدأ الآن" | ✅ منجز |
| 7 | **إنشاء حساب (Sign Up)** | الاسم، البريد، كلمة المرور وتأكيدها، إظهار/إخفاء الباسورد، Validation كامل | ✅ منجز |
| 8 | **تسجيل الدخول (Login)** | البريد، كلمة المرور، إظهار/إخفاء، رابط نسيت كلمة المرور، رابط إنشاء حساب | ✅ منجز |
| 9 | **تسجيل الخروج (Logout)** | زر خروج في Profile، إبطال Sanctum Token، ومسح `SharedPreferences` | ✅ منجز |
| 10 | **استعادة كلمة المرور** | شاشة Forgot Password، إرسال الطلب إلى الـ API | ✅ منجز |
| 11 | **إرسال رمز الـ OTP عبر الإيميل** | كود 6 أرقام مرسل عبر **Laravel Notifications** (`SendOtpNotification`) | ✅ منجز |
| 12 | **شاشة التحقق (Verify Code)** | عرض البريد، حقل إدخال رمز التحقق (OTP)، زر تحقق، خيار إعادة الإرسال | ✅ منجز |
| 13 | **إعادة تعيين كلمة المرور** | كلمة مرور جديدة، تأكيدها، إظهار وإخفاء، ورسالة نجاح ثم تسجيل الدخول | ✅ منجز |
| 14 | **شريط التنقل السفلي** | 3 صفحات على الأقل (الرئيسية، المفضلة، حسابي) | ✅ منجز |
| 15 | **جلب البيانات من الـ API** | عرض القطط بالكامل من قاعدة البيانات عبر Laravel API بدون بيانات ثابتة | ✅ منجز |

---

## 🏗️ هيكلية المشروع (Project Architecture)

```
final_projectV2/
├── mishmish/                      # تطبيق Flutter المكتمل
│   ├── lib/
│   │   ├── main.dart              # نقطة البداية، دعم RTL واللغة العربية
│   │   ├── config/
│   │   │   └── theme.dart         # ثيم التطبيق الموحد والألوان
│   │   ├── models/
│   │   │   ├── kitten.dart        # نموذج بيانات القطط
│   │   │   └── user.dart          # نموذج بيانات المستخدم
│   │   ├── services/
│   │   │   └── api_service.dart   # إدارة اتصالات الـ API والـ Tokens (دعم تلقائي للمحاكي والجهاز الحقيقي)
│   │   └── screens/
│   │       ├── splash_screen.dart             # شاشة البداية مع التوجيه الذكي
│   │       ├── onboarding/onboarding_screen.dart # 3 شاشات تعريفية
│   │       ├── auth/                          # شاشات المصادقة وإعادة التعيين
│   │       │   ├── login_screen.dart
│   │       │   ├── signup_screen.dart
│   │       │   ├── forgot_password_screen.dart
│   │       │   ├── verify_code_screen.dart
│   │       │   └── reset_password_screen.dart
│   │       ├── home/
│   │       │   ├── home_screen.dart           # الحاوية الرئيسية وشريط التنقل السفلي
│   │       │   ├── home_tab.dart              # قائمة القطط من الـ API
│   │       │   └── kitten_detail_screen.dart  # تفاصيل القطة والتبني
│   │       ├── favorites/favorites_tab.dart   # المفضلة المحفوظة في قاعدة البيانات
│   │       └── profile/profile_tab.dart       # الملف الشخصي وزر تسجيل الخروج
│   ├── assets/icon/cat_icon.png   # أيقونة التطبيق الرسمية
│   ├── test/widget_test.dart      # اختبارات الواجهة الآلية
│   └── pubspec.yaml
│
└── mishmish-api/                  # خادم Laravel REST API
    ├── app/
    │   ├── Http/Controllers/Api/
    │   │   ├── AuthController.php             # تسجيل، دخول، خروج، OTP، إعادة تعيين
    │   │   ├── KittenController.php           # عرض القطط والتفاصيل
    │   │   └── FavoriteController.php         # إدارة المفضلة للمستخدم
    │   ├── Models/ (User, Kitten, Favorite)
    │   └── Notifications/
    │       └── SendOtpNotification.php        # كلاس إشعار إرسال رمز التحقق
    ├── routes/api.php                         # تعريف الـ 10 Endpoints
    ├── database/migrations/                   # جداول Users, Kittens, Favorites, Reset Tokens
    ├── database/seeders/                      # بيانات تجريبية (12 قطة ومستخدم افتراضي)
    └── tests/Feature/AuthFlowTest.php         # اختبارات دورة المصادقة بالكامل
```

---

## 🚀 دليل التشغيل السريع (Quick Start Guide)

### 1) تشغيل الـ Backend (Laravel API & MySQL)

1. الانتقال لمجلد الـ API:
   ```bash
   cd mishmish-api
   composer install
   ```

2. إعداد قاعدة البيانات في ملف `.env`:
   ```ini
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=mishmish
   DB_USERNAME=root
   DB_PASSWORD=
   ```
   > *(ملاحظة: يمكنك إنشاء قاعدة بيانات باسم `mishmish` عبر phpMyAdmin أو MySQL CLI)*

3. إنشاء الجداول وتوليد البيانات التجريبية:
   ```bash
   php artisan key:generate
   php artisan migrate --seed
   ```

4. تشغيل السيرفر:
   ```bash
   php artisan serve --host=0.0.0.0 --port=8000
   ```
   - الرابط المحلي: `http://127.0.0.1:8000`
   - للأجهزة الحقيقية: استبدل بـ IP جهاز الكمبيوتر على نفس شبكة الـ Wi-Fi.

> **بيانات حساب تجريبي جاهز:**  
> - **البريد:** `user@mishmish.com`  
> - **كلمة المرور:** `123456`

---

### 2) تشغيل تطبيق الـ Flutter

1. الانتقال لمجلد التطبيق وتثبيت الحزم:
   ```bash
   cd mishmish
   flutter pub get
   ```

2. تشغيل التطبيق على المحاكي أو الجهاز:
   ```bash
   flutter run
   ```

> **ملاحظة بخصوص الاتصال بالسيرفر:**  
> تم ضبط كلاس `ApiService` ليتعرف تلقائياً على البيئة:
> - على **Android Emulator**: يتصل تلقائياً بـ `http://10.0.2.2:8000/api` (وهو المعيار في محاكي الأندرويد للوصول للـ localhost).
> - على **Web / iOS Simulator / Desktop**: يتصل تلقائياً بـ `http://127.0.0.1:8000/api`.
> - على **جهاز حقيقي عبر Wi-Fi**: يمكنك تعديل `overrideHost` في سطر 9 بملف `lib/services/api_service.dart`.

---

## 🧪 فحص الجودة والاختبارات الآلية

- **فحص كود الفلاتر (Clean Code / Zero Lints):**
  ```bash
  cd mishmish
  flutter analyze
  # النتيجة: No issues found!
  ```

- **تشغيل اختبارات Flutter:**
  ```bash
  flutter test
  # النتيجة: All tests passed!
  ```

- **تشغيل اختبارات Laravel:**
  ```bash
  cd mishmish-api
  php artisan test
  # النتيجة: 5 passed, 17 assertions
  ```

---

## 📧 تجربة استعادة كلمة المرور (OTP Verification)

1. من شاشة تسجيل الدخول اضغط على **"نسيت كلمة المرور؟"**.
2. أدخل بريد مسجل (مثل: `user@mishmish.com`) واضغط **"إرسال رمز التحقق"**.
3. يرسل Laravel إشعاراً رسمياً عبر `SendOtpNotification` يحتوي على كود تحقق مكون من 6 أرقام.
4. لمشاهدة الإيميل أو الكود المرسل أثناء التقييم دون الحاجة لـ SMTP خارجي، يتم تسجيله فوراً في:
   ```bash
   tail -n 25 mishmish-api/storage/logs/laravel.log
   ```
5. أدخل الرمز في شاشة التحقق ثم قم بتعيين كلمة المرور الجديدة لتسجيل الدخول بها بنجاح.
