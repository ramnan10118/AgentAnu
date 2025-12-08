# Sunset - Post-Demise Financial Asset Management System

A hackathon project for helping families access financial assets after a loved one passes away.

## 🏗️ Project Structure

```
sunset-hackathon/
├── backend/               # Node.js + Express + Socket.io server
├── main_app/              # Flutter app for Account Holders
├── companion_app/         # Flutter app for Next of Kin (NOK)
└── README.md             # This file
```

## 🚀 Prerequisites

### Required Software

1. **Node.js** (v18 or higher)
   - Download: https://nodejs.org/
   - Verify: `node --version`

2. **Flutter** (v3.35.0 or higher)
   - Install: https://docs.flutter.dev/get-started/install
   - Verify: `flutter --version`

3. **Git**
   - Verify: `git --version`

## 📦 Setup Instructions

### 1. Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Start the server
npm start

# Or use nodemon for development (auto-restart)
npm run dev
```

The backend will start on **http://localhost:3000**

### 2. Main App Setup (Account Holder App)

```bash
# Navigate to project root
cd ..

# Create Flutter project
flutter create main_app

# Navigate to main_app and implement the app
cd main_app

# Get dependencies (after setting up pubspec.yaml)
flutter pub get

# Run on web
flutter run -d chrome
```

### 3. Companion App Setup (NOK App)

```bash
# Navigate to project root
cd ..

# Create Flutter project
flutter create companion_app

# Navigate to companion_app and implement the app
cd companion_app

# Get dependencies (after setting up pubspec.yaml)
flutter pub get

# Run on web
flutter run -d chrome
```

## 🎯 Quick Start Guide

### Demo Flow (5 minutes)

1. **Start Backend**
   ```bash
   cd backend
   npm run dev
   ```
   Backend runs on http://localhost:3000

2. **Start Main App**
   ```bash
   cd main_app
   flutter run -d chrome
   ```

3. **Start Companion App** (in another terminal)
   ```bash
   cd companion_app
   flutter run -d chrome
   ```

4. **Demo Scenario**
   - **Main App**: Register with mobile `+919876543210`, OTP `123456`, PAN `ABCDE1234F`
   - **Main App**: View assets, designate NOK with mobile `+919123456789`
   - **Companion App**: Login with mobile `+919123456789`, OTP `123456`
   - **Companion App**: Accept designation
   - **Main App**: Receive real-time notification
   - **Companion App**: Upload death certificate → View revealed assets

## 🔑 Demo Credentials

### Mock OTP (Always)
```
123456
```

### Sample PAN Numbers with Pre-loaded Assets

**PAN: ABCDE1234F** (Rajesh Kumar - ₹61,00,000)
- 2 Bank Accounts
- 2 Mutual Funds
- 1 Insurance Policy
- 1 Fixed Deposit
- 1 NPS Account
- 1 Securities Account

**PAN: XYZAB5678C** (Priya Sharma - ₹35,00,000)
- 1 Bank Account
- 1 Mutual Fund
- 1 Insurance Policy
- 1 NPS Account

**PAN: PQRST9012G** (Amit Patel - ₹19,00,000)
- 1 Bank Account
- 1 Mutual Fund
- 1 Fixed Deposit

### Sample Mobile Numbers
- Account Holder: `+919876543210` or any 10-digit number
- NOK: `+919123456789` or any 10-digit number

## 🔧 Development

### Backend API Endpoints

**Authentication:**
- `POST /api/auth/send-otp` - Send OTP to mobile
- `POST /api/auth/verify-otp` - Verify OTP and login
- `POST /api/auth/validate-pan` - Validate PAN
- `GET /api/auth/me` - Get current user

**Assets:**
- `POST /api/assets/consent` - Consent to fetch assets
- `GET /api/assets/fetch` - Fetch assets from Anumati (mock)
- `GET /api/assets` - Get stored assets
- `GET /api/assets/revealed/:userId` - Get revealed assets (NOK only)

**NOK Management:**
- `POST /api/nok/designate` - Designate NOK
- `GET /api/nok/status` - Get designation status
- `GET /api/nok/designations` - Get designations for NOK
- `POST /api/nok/accept/:id` - Accept designation
- `POST /api/nok/reject/:id` - Reject designation
- `DELETE /api/nok/revoke` - Revoke designation

**Death & Claims:**
- `POST /api/death/upload-certificate` - Upload death certificate
- `GET /api/death/status/:id` - Check verification status
- `POST /api/death/verify/:userId` - Manually verify certificate
- `POST /api/death/yellow-handoff` - Create Yellow handoff
- `GET /api/death/claims-guidance/:assetType` - Get claims guidance

### WebSocket Events

**Client → Server:**
- `authenticate` - Authenticate socket with token
- `nok:designate` - Trigger designation notification
- `nok:accept` - Trigger acceptance notification
- `nok:reject` - Trigger rejection notification

**Server → Client:**
- `authenticated` - Authentication successful
- `nok:designated` - NOK designation received
- `nok:accepted` - NOK accepted designation
- `nok:rejected` - NOK rejected designation
- `death:verified` - Death certificate verified
- `error` - Error message

## 📱 Flutter Dependencies

Add these to `pubspec.yaml` for both apps:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0

  # Networking
  dio: ^5.3.3
  socket_io_client: ^2.0.3

  # UI Library
  forui: ^0.4.0

  # Utilities
  uuid: ^4.1.0
  intl: ^0.18.1
  file_picker: ^6.0.0
  shared_preferences: ^2.2.2
```

## 🎨 UI Library

This project uses **Forui** (https://forui.dev/) - a Flutter UI library inspired by shadcn/ui.

## 📝 Implementation Status

### ✅ Completed
- ✅ Backend Node.js server with Express
- ✅ Socket.io real-time communication
- ✅ In-memory database models
- ✅ Mock services (OTP, Anumati, Yellow)
- ✅ REST API endpoints (all routes)
- ✅ WebSocket event handlers
- ✅ Authentication middleware

### 🚧 To Be Implemented
- ⏳ Flutter Main App screens and logic
- ⏳ Flutter Companion App screens and logic
- ⏳ UI components using Forui
- ⏳ State management with Riverpod
- ⏳ API and Socket services in Flutter

## 📖 Architecture

### Backend
- **Express.js**: REST API server
- **Socket.io**: Real-time WebSocket communication
- **In-Memory Storage**: Maps for users, assets, designations
- **Mock Services**: Simulated OTP, Anumati, Yellow

### Frontend (Flutter)
- **Riverpod**: State management
- **Dio**: HTTP client
- **Socket.io Client**: WebSocket connection
- **Forui**: UI components
- **Responsive Design**: Mobile-first approach

### Data Flow
1. Account holder registers → fetches mock assets
2. Designates NOK → Real-time notification via WebSocket
3. NOK receives notification → Accepts designation
4. Account holder receives acceptance → Real-time via WebSocket
5. NOK uploads death certificate → Auto-verified (5 seconds)
6. NOK receives verification → Assets revealed

## 🏆 Hackathon Tips

### Key Features to Showcase
- **Real-time notifications** between Main and Companion apps
- **Mobile number linking** - NOK uses their own number
- **Privacy**: NOK sees nothing until death verified
- **Comprehensive assets** - Multiple types displayed

### Common Issues
- **Data resets**: Backend is in-memory, restart = fresh state
- **Socket disconnects**: Refresh page to reconnect
- **Asset loading**: Mock delay is 1.5 seconds
- **Death verification**: Auto-verifies after 5 seconds

---

**Happy Hacking! 🚀**