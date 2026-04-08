# 📚 67-E Book
### ITDS283 Section 2 — Group 7

> แอปพลิเคชัน E-Book Marketplace สำหรับซื้อ-ขายหนังสือดิจิทัล  
> พัฒนาด้วย **Flutter** (Mobile) + **Node.js/Express** (Backend) + **PostgreSQL** (Database)

---

## 👥 สมาชิกกลุ่ม

| รหัสนักศึกษา | ชื่อ-สกุล |
|---|---|
| 6787087 | — |
| 6787122 | — |

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter 3.x (Dart) |
| Backend | Node.js + Express 5 |
| Database | PostgreSQL |
| ORM | Prisma v7 + Driver Adapter (pg) |
| Authentication | JWT + Firebase Auth (Google Sign-In) |
| File Upload | Multer (image + PDF) |
| Payment | PromptPay QR (promptpay-qr) |
| State Management | InheritedNotifier (ไม่ใช้ package เพิ่ม) |
| Image Cache | cached_network_image |

---

## 📁 โครงสร้างโปรเจกต์

```
ITDS283_Sec2_Group7_Code/
│
├── itds283_sec2_group7_code_be/          ← Node.js Backend
│   ├── server.js
│   ├── app.js
│   ├── .env
│   ├── prisma/
│   │   └── schema.prisma
│   ├── configs/
│   │   └── db.js                         ← Prisma Client
│   ├── controllers/
│   │   ├── auth_controller.js
│   │   ├── book_controller.js
│   │   ├── cart_controller.js
│   │   ├── order_controller.js
│   │   └── user_controller.js
│   ├── services/
│   │   ├── auth_services.js
│   │   ├── book_services.js
│   │   ├── cart_services.js
│   │   └── order_services.js
│   ├── middlewares/
│   │   ├── auth_middleware.js
│   │   └── upload_middleware.js
│   └── routes/
│       ├── index.js
│       ├── auth_routes.js
│       ├── book_routes.js
│       ├── cart_routes.js
│       ├── order_routes.js
│       └── user_routes.js
│
└── itds283_sec2_group7_code_mobile/      ← Flutter App
    └── lib/
        ├── main.dart
        ├── firebase_options.dart
        ├── providers/
        │   ├── auth_provider.dart
        │   ├── cart_provider.dart
        │   ├── favorite_provider.dart
        │   └── library_provider.dart
        ├── routes/
        │   └── app_routes.dart
        ├── screens/
        │   ├── splash_screen.dart
        │   ├── login_screen.dart
        │   ├── signup_screen.dart
        │   ├── main_screen.dart
        │   ├── home_screen.dart
        │   ├── product_screen.dart
        │   ├── product_detail_screen.dart
        │   ├── search_screen.dart
        │   ├── cart_screen.dart
        │   ├── checkout_screen.dart
        │   ├── user_screen.dart
        │   ├── favorites_screen.dart
        │   ├── library_screen.dart
        │   ├── read_screen.dart
        │   ├── my_products_screen.dart
        │   ├── add_product_screen.dart
        │   └── edit_product_screen.dart
        └── widgets/
            ├── product_card.dart
            └── cart_item_card.dart
```

---

## 🚀 วิธีติดตั้งและรัน

### Backend

```bash
cd itds283_sec2_group7_code_be

# 1. ติดตั้ง dependencies
npm install

# 2. สร้างไฟล์ .env
```

**ตัวอย่าง `.env`**
```env
DATABASE_URL="postgresql://user:password@localhost:5432/ebook_db"
JWT_SECRET="your_super_secret_key_here"
JWT_EXPIRES_IN="7d"
PORT=3030
```

```bash
# 3. Generate Prisma Client
npx prisma generate

# 4. Migrate database
npx prisma migrate dev

# 5. รัน server (development)
npm run dev
```

Server จะรันที่ `http://localhost:3030`  
Health check: `http://localhost:3030/api/health`

---

### Mobile (Flutter)

```bash
cd itds283_sec2_group7_code_mobile

# 1. ติดตั้ง dependencies
flutter pub get

# 2. Setup Firebase (ครั้งแรก)
dart pub global activate flutterfire_cli
flutterfire configure
# → จะได้ไฟล์ lib/firebase_options.dart อัตโนมัติ

# 3. วาง GoogleService-Info.plist ใน ios/Runner/
#    (download จาก Firebase Console)

# 4. เพิ่ม REVERSED_CLIENT_ID ใน ios/Runner/Info.plist
#    (ค่าจาก GoogleService-Info.plist)

# 5. รันแอป
flutter run
```

---

## 🔌 API Endpoints

**Base URL:** `https://ebookapi.arlifzs.site/api`  
**Auth Header:** `Authorization: Bearer <token>`

### Auth
| Method | Endpoint | Auth | Body / คำอธิบาย |
|---|---|---|---|
| POST | `/auth/register` | ❌ | `email, password, firstName, lastName, phone?, dob?` |
| POST | `/auth/login` | ❌ | `email, password` → คืน `token` |
| POST | `/auth/google-login` | ❌ | `googleId, email, firstName, lastName` |
| GET | `/auth/me` | ✅ | ดูข้อมูลตัวเอง |

### Books
| Method | Endpoint | Auth | คำอธิบาย |
|---|---|---|---|
| GET | `/books` | ❌ | ดูหนังสือทั้งหมด (`?search=`, `?category=`) |
| GET | `/books/:id` | ❌ | ดูหนังสือตาม ID |
| GET | `/books/seller/my-books` | ✅ SELLER | ดูหนังสือของตัวเอง |
| POST | `/books` | ✅ SELLER | เพิ่มหนังสือ (multipart: image + pdf) |
| PUT | `/books/:id` | ✅ SELLER | แก้ไขหนังสือ |
| DELETE | `/books/:id` | ✅ SELLER | ลบหนังสือ + ไฟล์ |

### Cart
| Method | Endpoint | Auth | คำอธิบาย |
|---|---|---|---|
| GET | `/cart` | ✅ | ดูตะกร้า |
| POST | `/cart/add` | ✅ | `{ bookId }` เพิ่มหนังสือ |
| DELETE | `/cart/remove/:id` | ✅ | ลบ CartItem |

### Orders
| Method | Endpoint | Auth | คำอธิบาย |
|---|---|---|---|
| POST | `/orders/promo` | ✅ | `{ code }` ตรวจสอบโปรโมโค้ด |
| POST | `/orders/checkout` | ✅ | ชำระเงิน → หนังสือเข้า Library อัตโนมัติ |
| GET | `/orders/history` | ✅ | ประวัติการสั่งซื้อ |
| GET | `/orders/qr-payment` | ✅ | สร้าง QR PromptPay จากยอดตะกร้า |

### Users
| Method | Endpoint | Auth | คำอธิบาย |
|---|---|---|---|
| GET | `/users/profile` | ✅ | ดูโปรไฟล์ |
| PUT | `/users/profile` | ✅ | `{ firstName, lastName }` แก้ชื่อ |
| GET | `/users/favorites` | ✅ | ดูหนังสือที่ถูกใจ |
| POST | `/users/favorites/toggle` | ✅ | `{ bookId }` toggle ถูกใจ |
| GET | `/users/library` | ✅ | ดูคลังหนังสือที่ซื้อแล้ว |
| PUT | `/users/library/:bookId/progress` | ✅ | `{ currentPage, bookmarkedPages, isDownloaded }` |

---

## 📱 หน้าจอในแอป

| หน้า | คำอธิบาย |
|---|---|
| **Splash** | แสดงโลโก้ 3 วิ → redirect ตาม login state |
| **Login** | Email/Password + Google Sign-In |
| **Sign Up** | สมัครสมาชิก พร้อม Date Picker |
| **Home** | Banner, Categories (กรองหนังสือ), Best Seller, New Collection |
| **Product** | หนังสือทั้งหมด กรองตาม category + pull-to-refresh |
| **Product Detail** | รายละเอียด, Add to Cart / Buy Now / Read Now (ถ้าซื้อแล้ว) |
| **Search** | ค้นหาผ่าน API real-time |
| **Cart** | จัดการตะกร้า, promo code, ยอดรวม |
| **Checkout** | กรอกที่อยู่ → เลือกวิธีชำระ → QR PromptPay → สำเร็จ |
| **User** | โปรไฟล์ (แก้ชื่อได้), My Favorites, My Library, My Products (SELLER) |
| **My Favorites** | หนังสือที่กดถูกใจ ดึงจาก API |
| **Library** | หนังสือที่ซื้อแล้ว + ดาวน์โหลด PDF จริง |
| **Read** | อ่านหนังสือ, bookmark, slider ข้ามหน้า, download |
| **My Products** | SELLER: จัดการหนังสือ (เพิ่ม/แก้ไข/ลบ) |
| **Add/Edit Product** | อัปโหลด image + PDF จริงผ่าน API |

---

## 🗄️ Database Schema

```
User        — ข้อมูลผู้ใช้ (Role: BUYER / SELLER)
Book        — หนังสือ (title, author, category, price, imageUrl, pdfUrl)
Cart        — ตะกร้า (1 ต่อ 1 User)
CartItem    — รายการในตะกร้า
Order       — คำสั่งซื้อ (พร้อมข้อมูลที่อยู่จัดส่ง)
OrderItem   — รายการในคำสั่งซื้อ
Favorite    — หนังสือที่ถูกใจ
LibraryItem — คลังหนังสือหลังซื้อ (+ isDownloaded, currentPage, bookmarkedPages)
PromoCode   — โปรโมโค้ด
```

---

## 📦 Dependencies หลัก

### Flutter (`pubspec.yaml`)
```yaml
# Firebase
firebase_core, firebase_auth, google_sign_in

# Networking
http, cached_network_image

# File
file_picker, image_picker, path_provider, path, http_parser

# Storage
shared_preferences

# UI
remixicon
```

### Node.js (`package.json`)
```json
"dependencies": {
  "express": "^5.2.1",
  "cors": "^2.8.6",
  "dotenv": "^17.3.1",
  "@prisma/client": "^7.6.0",
  "@prisma/adapter-pg": "^7.6.0",
  "pg": "^8.x",
  "bcrypt": "^6.0.0",
  "jsonwebtoken": "^9.0.3",
  "multer": "^1.x",
  "promptpay-qr": "^0.6.x"
}
```

---

## ⚙️ Features พิเศษ

- **Offline Cache** — Library provider cache ข้อมูลไว้ใน SharedPreferences อ่านได้แม้ไม่มีเน็ต
- **PDF Download** — ดาวน์โหลด PDF จริงเก็บในเครื่อง ลบได้
- **Role-based UI** — SELLER เห็น Seller Zone, BUYER ไม่เห็น
- **Smart Cart** — ป้องกันเพิ่มหนังสือซ้ำ และป้องกันซื้อหนังสือที่มีในคลังแล้ว
- **Auto Library** — หลัง checkout หนังสือเข้า Library อัตโนมัติ ตะกร้าถูกล้าง
- **Real-time Search** — ค้นหาผ่าน API ทุกครั้งที่พิมพ์
