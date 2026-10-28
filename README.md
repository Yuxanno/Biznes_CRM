# Business Manager App

A full-stack CRM for small business owners. Manage orders, transactions, debts, and clients.

**Stack:** Flutter (mobile) + Next.js 14 (API) + MongoDB + GridFS

---

## Project Structure

```
/backend    — Next.js 14 API (port 3001)
/frontend   — Flutter mobile app
```

---

## Backend Setup

### Requirements
- Node.js 18+
- MongoDB (local or Atlas)

### Install & run

```bash
cd backend
npm install
```

Copy `.env.example` to `.env` and fill in your values:

```env
MONGODB_URI=mongodb://localhost:27017/business_manager
JWT_SECRET=your_super_secret_key_here
NEXT_PUBLIC_APP_URL=http://localhost:3001
```

```bash
# Development
npm run dev

# Seed demo data (username: demo, password: demo123)
npx ts-node scripts/seed.ts
```

The API will be available at `http://localhost:3001/api`.

---

## Frontend Setup

### Requirements
- Flutter 3.x SDK
- Android Studio / Xcode for emulator

### Configure API URL

Edit `lib/config/app_config.dart`:

```dart
static const String baseUrl = 'http://localhost:3001/api';
// For Android emulator use: 'http://10.0.2.2:3001/api'
// For physical device use your machine's local IP
```

### Install & run

```bash
cd frontend
flutter pub get
flutter run
```

---

## API Overview

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register user |
| POST | `/api/auth/login` | Login |
| GET | `/api/dashboard` | Dashboard stats |
| GET/POST | `/api/transactions` | List / create transactions |
| GET/PUT/DELETE | `/api/transactions/:id` | Single transaction |
| GET/POST | `/api/orders` | List / create orders |
| GET/PUT/DELETE | `/api/orders/:id` | Single order |
| POST/DELETE | `/api/orders/:id/photos` | Upload / delete photos |
| POST/DELETE | `/api/orders/:id/audio` | Upload / delete audio |
| GET | `/api/files/:id` | Stream file from GridFS |
| GET/POST | `/api/debts` | List / create debts |
| PUT/DELETE | `/api/debts/:id` | Update / delete debt |
| GET/POST | `/api/customers` | List / create customers |
| GET/PUT/DELETE | `/api/customers/:id` | Single customer |
| GET/POST | `/api/periods` | List / create periods |
| GET | `/api/periods/:id` | Period detail |
| GET/POST | `/api/categories` | List / create categories |
| PUT/DELETE | `/api/categories/:id` | Update / delete category |
| GET | `/api/notifications` | Get notifications |
| PATCH | `/api/notifications` | Mark all as read |

All authenticated routes require `Authorization: Bearer <token>` header.

---

## Features

- **Dashboard** — income/expense overview, charts, upcoming deadlines
- **Transactions** — income/expense with category filter and pagination
- **Orders** — track client orders with status, photos, and voice notes
- **Debts** — track money owed to you and money you owe
- **Customers** — client directory with order/debt history
- **Business Periods** — segment data by time period (quarters, years)
- **Notifications** — automatic alerts for overdue orders and debts
"# Biznes_CRM" 
"# Biznes_CRM" 
