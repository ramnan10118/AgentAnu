# Detailed Setup Guide for Sunset Hackathon

This guide provides step-by-step instructions for setting up the complete Sunset project.

## Prerequisites Installation

### 1. Install Node.js

**macOS:**
```bash
# Using Homebrew
brew install node

# Or download from nodejs.org
# https://nodejs.org/en/download/
```

**Verify Installation:**
```bash
node --version  # Should show v18+ or higher
npm --version   # Should show 9+ or higher
```

### 2. Install Flutter

**macOS:**
```bash
# Download Flutter SDK
cd ~
git clone https://github.com/flutter/flutter.git -b stable

# Add Flutter to PATH (add to ~/.zshrc or ~/.bash_profile)
export PATH="$PATH:`pwd`/flutter/bin"

# Reload shell
source ~/.zshrc  # or source ~/.bash_profile

# Run Flutter doctor
flutter doctor
```

**Enable Web Support:**
```bash
flutter config --enable-web
flutter doctor
```

## Backend Setup (Detailed)

### Step 1: Navigate to Backend
```bash
cd /Users/ramnan.arumugam/Documents/AgentAnu/backend
```

### Step 2: Install Dependencies
```bash
npm install
```

This will install:
- express (REST API server)
- socket.io (WebSocket server)
- cors (Cross-origin requests)
- uuid (ID generation)
- jsonwebtoken (Authentication)
- multer (File uploads)
- dotenv (Environment variables)
- nodemon (Auto-restart dev server)

### Step 3: Verify .env File
The `.env` file should already exist with:
```
PORT=3000
JWT_SECRET=sunset-hackathon-secret-key-change-in-production
NODE_ENV=development
MOCK_OTP=123456
AUTO_VERIFY_DEATH_CERT=true
VERIFICATION_DELAY_MS=5000
```

### Step 4: Start Backend Server
```bash
# Production mode
npm start

# Development mode (auto-restart on changes)
npm run dev
```

### Step 5: Verify Backend is Running
Open browser and go to: http://localhost:3000

You should see:
```json
{
  "name": "Sunset API",
  "version": "1.0.0",
  "description": "Post-demise financial asset management system"
}
```

Test health endpoint: http://localhost:3000/health

### Backend Troubleshooting

**Port 3000 already in use:**
```bash
# Find process using port 3000
lsof -i :3000

# Kill process
kill -9 <PID>

# Or change port in .env file
PORT=3001
```

**Module not found errors:**
```bash
# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

## Flutter Apps Setup (Detailed)

### Main App (Account Holder) Setup

#### Step 1: Create Flutter Project
```bash
cd /Users/ramnan.arumugam/Documents/AgentAnu
flutter create main_app
cd main_app
```

#### Step 2: Update pubspec.yaml
Replace the dependencies section in `pubspec.yaml`:

```yaml
name: main_app
description: Sunset Main App for Account Holders
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

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

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

#### Step 3: Install Dependencies
```bash
flutter pub get
```

#### Step 4: Create Project Structure
```bash
mkdir -p lib/{config,models,providers,services,screens,widgets,utils}
mkdir -p lib/screens/{auth,onboarding,nok,dashboard}
```

#### Step 5: Create API Config
Create `lib/config/api_config.dart`:
```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api';
  static const String socketUrl = 'http://localhost:3000';

  // For different environments
  static String get environment => const String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );
}
```

#### Step 6: Run Main App
```bash
# Run on Chrome (web)
flutter run -d chrome

# Or build for web
flutter build web
```

### Companion App (NOK) Setup

#### Step 1: Create Flutter Project
```bash
cd /Users/ramnan.arumugam/Documents/AgentAnu
flutter create companion_app
cd companion_app
```

#### Step 2-6: Same as Main App
Follow the same steps as Main App setup, using the same `pubspec.yaml` dependencies.

### Flutter Troubleshooting

**Flutter command not found:**
```bash
# Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"

# Or reinstall Flutter
```

**Web support not enabled:**
```bash
flutter config --enable-web
flutter create . --platforms web
```

**Dependencies not installing:**
```bash
# Clean and reinstall
flutter clean
flutter pub get

# Or update Flutter
flutter upgrade
```

**Chrome not found:**
```bash
# On macOS, Chrome should be automatically detected
# Or specify Chrome path
flutter run -d chrome --web-browser-flag="--disable-web-security"
```

## Testing the Complete Flow

### 1. Start Backend
```bash
cd backend
npm run dev
```

Wait for:
```
🌅 Sunset Backend Server
Status: ✅ Running
Port: 3000
```

### 2. Start Main App
```bash
cd main_app
flutter run -d chrome
```

### 3. Start Companion App (New Terminal)
```bash
cd companion_app
flutter run -d chrome
```

### 4. Run Demo Flow

**In Main App (Chrome Tab 1):**
1. Open http://localhost:PORT (Flutter will show the port)
2. Enter mobile: `+919876543210`
3. Click "Send OTP" → OTP: `123456`
4. Enter PAN: `ABCDE1234F`
5. Consent to fetch assets
6. View assets (₹61,00,000)
7. Designate NOK:
   - Name: "Jane Doe"
   - Mobile: `+919123456789`
   - Relationship: "Spouse"
8. Wait for acceptance notification

**In Companion App (Chrome Tab 2):**
1. Open http://localhost:PORT2
2. Enter mobile: `+919123456789`
3. OTP: `123456`
4. See designation from "Rajesh Kumar"
5. Accept designation
6. See confirmation

**Back in Main App:**
- Receive real-time "NOK Accepted" notification

**In Companion App (Death Flow):**
1. Click "Initiate Retrieval"
2. Upload any PDF as death certificate
3. Wait 5 seconds for auto-verification
4. View all revealed assets (₹61,00,000)

## Environment Variables

### Backend (.env)
```bash
PORT=3000                          # Server port
JWT_SECRET=your-secret-key         # JWT signing key
NODE_ENV=development               # development or production
MOCK_OTP=123456                    # Always use this OTP
AUTO_VERIFY_DEATH_CERT=true       # Auto-verify for hackathon
VERIFICATION_DELAY_MS=5000         # Delay before auto-verify
```

### Flutter (api_config.dart)
```dart
// Development
baseUrl: 'http://localhost:3000/api'
socketUrl: 'http://localhost:3000'

// Production (if deployed)
baseUrl: 'https://your-backend.com/api'
socketUrl: 'https://your-backend.com'
```

## Common Issues & Solutions

### Backend Issues

**1. Cannot find module 'express'**
```bash
cd backend
npm install
```

**2. Address already in use**
```bash
lsof -i :3000
kill -9 <PID>
```

**3. CORS errors in browser**
- Backend already has CORS enabled
- Check that backend URL in Flutter matches

### Flutter Issues

**1. Pub get failed**
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

**2. WebSocket connection refused**
- Make sure backend is running
- Check API config URLs
- Check browser console for errors

**3. Hot reload not working**
```bash
# Press 'r' in terminal for hot reload
# Press 'R' for hot restart
# Or stop and run again
```

### General Issues

**1. Real-time notifications not working**
- Check backend logs for socket connections
- Verify socket authentication
- Check browser network tab for WebSocket

**2. Data not persisting**
- This is expected - backend uses in-memory storage
- Data resets on server restart

**3. Assets not loading**
- Verify PAN number is correct
- Check backend logs for asset fetch
- Default PANs: `ABCDE1234F`, `XYZAB5678C`, `PQRST9012G`

## Next Steps

1. ✅ Backend running
2. ⏳ Implement Flutter screens
3. ⏳ Add Forui components
4. ⏳ Implement Riverpod providers
5. ⏳ Connect API and Socket services
6. ⏳ Test complete flow
7. ⏳ Polish UI and UX
8. ⏳ Prepare demo presentation

## Resources

- **Forui Docs**: https://forui.dev/docs
- **Riverpod Docs**: https://riverpod.dev/
- **Socket.io Client**: https://socket.io/docs/v4/client-api/
- **Dio HTTP Client**: https://pub.dev/packages/dio

## Support

For issues during the hackathon:
- Check backend logs: Look at terminal running `npm run dev`
- Check Flutter logs: Look at terminal running `flutter run`
- Check browser console: Press F12 in Chrome
- Check network tab: F12 → Network → See API calls and WebSocket

---

**Good luck with your hackathon! 🚀**
