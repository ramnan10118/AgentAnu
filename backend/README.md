# Sunset Backend Server

Node.js + Express + Socket.io backend for the Sunset hackathon project.

## Features

- ✅ REST API for authentication, assets, NOK management, and death verification
- ✅ Real-time WebSocket communication for NOK designation and acceptance
- ✅ In-memory database (no external database required)
- ✅ Mock services for OTP, Anumati (Account Aggregator), and Yellow (Claims)
- ✅ Auto-verification of death certificates for demo purposes

## Quick Start

```bash
# Install dependencies
npm install

# Start server (production)
npm start

# Start server (development with auto-reload)
npm run dev
```

Server runs on http://localhost:3000

## Project Structure

```
backend/
├── src/
│   ├── server.js              # Main server file
│   ├── routes/
│   │   ├── auth.js           # Authentication endpoints
│   │   ├── assets.js         # Asset management endpoints
│   │   ├── nok.js            # NOK designation endpoints
│   │   └── death.js          # Death certificate endpoints
│   ├── socket/
│   │   └── handlers.js       # WebSocket event handlers
│   ├── models/
│   │   └── index.js          # In-memory database
│   ├── services/
│   │   ├── mockOTP.js        # Mock OTP service
│   │   ├── mockAnumati.js    # Mock Anumati integration
│   │   └── mockYellow.js     # Mock Yellow integration
│   ├── middleware/
│   │   └── auth.js           # Authentication middleware
│   └── utils/
│       └── helpers.js        # Utility functions
├── package.json
├── .env                       # Environment variables
└── README.md                 # This file
```

## API Endpoints

### Authentication (`/api/auth`)

```
POST /api/auth/send-otp
Body: { mobile: "+919876543210" }
Response: { success: true, otp: "123456" }

POST /api/auth/verify-otp
Body: { mobile: "+919876543210", otp: "123456" }
Response: { success: true, token: "session-token", user: {...} }

POST /api/auth/validate-pan
Headers: Authorization: Bearer <token>
Body: { pan: "ABCDE1234F" }
Response: { success: true, user: {...} }

GET /api/auth/me
Headers: Authorization: Bearer <token>
Response: { success: true, user: {...} }
```

### Assets (`/api/assets`)

```
POST /api/assets/consent
Headers: Authorization: Bearer <token>
Body: { consented: true }
Response: { success: true }

GET /api/assets/fetch
Headers: Authorization: Bearer <token>
Response: { success: true, assets: [...], totalNetWorth: 6100000 }

GET /api/assets
Headers: Authorization: Bearer <token>
Response: { success: true, assets: [...], totalNetWorth: 6100000 }

GET /api/assets/revealed/:userId
Headers: Authorization: Bearer <token>
Response: { success: true, assets: [...], totalNetWorth: 6100000 }
```

### NOK Management (`/api/nok`)

```
POST /api/nok/designate
Headers: Authorization: Bearer <token>
Body: { nokMobile: "+919123456789", nokName: "Jane Doe", relationship: "spouse" }
Response: { success: true, designation: {...} }

GET /api/nok/status
Headers: Authorization: Bearer <token>
Response: { success: true, hasDesignation: true, designation: {...} }

GET /api/nok/designations
Headers: Authorization: Bearer <token>
Response: { success: true, designations: [...] }

POST /api/nok/accept/:designationId
Headers: Authorization: Bearer <token>
Response: { success: true, designation: {...} }

DELETE /api/nok/revoke
Headers: Authorization: Bearer <token>
Response: { success: true }
```

### Death & Claims (`/api/death`)

```
POST /api/death/upload-certificate
Headers: Authorization: Bearer <token>
Body: { accountHolderMobile: "+919876543210", fileName: "death_cert.pdf", fileData: "base64..." }
Response: { success: true, certificate: {...} }

GET /api/death/status/:accountHolderId
Headers: Authorization: Bearer <token>
Response: { success: true, certificate: {...} }

POST /api/death/yellow-handoff
Headers: Authorization: Bearer <token>
Body: { accountHolderId: "user-id" }
Response: { success: true, handoff: {...} }

GET /api/death/claims-guidance/:assetType
Headers: Authorization: Bearer <token>
Response: { success: true, guidance: {...} }
```

## WebSocket Events

### Connection & Auth

```javascript
// Client connects
socket.connect();

// Client authenticates
socket.emit('authenticate', { token: 'session-token' });

// Server confirms
socket.on('authenticated', (data) => {
  console.log('Authenticated:', data.userId);
});
```

### NOK Designation Flow

```javascript
// Account holder designates NOK (after API call)
socket.emit('nok:designate', { designationId: 'designation-id' });

// NOK receives notification
socket.on('nok:designated', (data) => {
  console.log('You have been designated by:', data.accountHolderName);
});

// NOK accepts (after API call)
socket.emit('nok:accept', { designationId: 'designation-id' });

// Account holder receives notification
socket.on('nok:accepted', (data) => {
  console.log('NOK accepted:', data.nokName);
});
```

### Death Verification Flow

```javascript
// After death certificate upload, backend auto-verifies after 5 seconds

// NOK receives verification notification
socket.on('death:verified', (data) => {
  console.log('Death certificate verified for:', data.accountHolderId);
  // Now NOK can view revealed assets
});
```

## Environment Variables

```bash
PORT=3000                          # Server port
JWT_SECRET=secret-key              # JWT signing key
NODE_ENV=development               # development or production
MOCK_OTP=123456                    # Always use this OTP
AUTO_VERIFY_DEATH_CERT=true       # Auto-verify for hackathon
VERIFICATION_DELAY_MS=5000         # Delay before auto-verify (ms)
```

## Mock Data

### Sample PAN Numbers

**ABCDE1234F** - Rajesh Kumar (₹61,00,000)
- 8 assets across all types

**XYZAB5678C** - Priya Sharma (₹35,00,000)
- 4 assets (bank, MF, insurance, NPS)

**PQRST9012G** - Amit Patel (₹19,00,000)
- 3 assets (bank, MF, FD)

### Asset Types

- `bank_account` - Bank accounts
- `mutual_fund` - Mutual funds
- `insurance` - Insurance policies
- `fd` - Fixed deposits
- `nps` - National Pension System
- `securities` - Demat/Securities

## Testing

### Using cURL

```bash
# Send OTP
curl -X POST http://localhost:3000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"mobile":"+919876543210"}'

# Verify OTP
curl -X POST http://localhost:3000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"mobile":"+919876543210","otp":"123456"}'

# Validate PAN
curl -X POST http://localhost:3000/api/auth/validate-pan \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"pan":"ABCDE1234F"}'

# Fetch assets
curl -X GET http://localhost:3000/api/assets/fetch \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Using Postman

1. Import the API endpoints
2. Set Authorization header: `Bearer YOUR_TOKEN`
3. Test each endpoint

## Development

### Adding New Routes

1. Create route file in `src/routes/`
2. Import in `src/server.js`
3. Register route: `app.use('/api/your-route', yourRoutes)`

### Adding New Socket Events

1. Add event handler in `src/socket/handlers.js`
2. Document event in README
3. Test with socket client

### Adding New Mock Data

1. Edit `src/services/mockAnumati.js`
2. Add new PAN with assets
3. Update README with new PAN

## Troubleshooting

**Port already in use:**
```bash
lsof -i :3000
kill -9 <PID>
# Or change PORT in .env
```

**Module not found:**
```bash
rm -rf node_modules
npm install
```

**WebSocket not connecting:**
- Check CORS settings in `src/server.js`
- Verify Socket.io client version matches
- Check browser console for errors

**Assets not loading:**
- Check PAN format: `^[A-Z]{5}[0-9]{4}[A-Z]$`
- Use sample PANs: `ABCDE1234F`, `XYZAB5678C`, `PQRST9012G`
- Check backend logs for errors

## Production Deployment

**Note:** This is a hackathon demo with in-memory storage. For production:

1. Add a real database (MongoDB, PostgreSQL)
2. Implement proper authentication (JWT with refresh tokens)
3. Add rate limiting
4. Enable HTTPS
5. Add logging (Winston, Morgan)
6. Add monitoring (PM2, New Relic)
7. Implement real OTP service (Twilio, AWS SNS)
8. Add API documentation (Swagger)
9. Add tests (Jest, Supertest)
10. Use environment-specific configs

## License

MIT License - Hackathon Project
