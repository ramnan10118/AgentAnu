/**
 * Test script to verify NOK designation socket flow
 * Run with: node test_nok_flow.js
 */

import db from './src/models/index.js';

console.log('\n🧪 Testing NOK Designation Socket Flow\n');
console.log('=' .repeat(50));

// Step 1: Create account holder user
console.log('\n1️⃣ Creating account holder user...');
const accountHolder = db.createUser({
  mobile: '+919999999999',
  name: 'John Doe',
  role: 'account_holder'
});
console.log('✅ Account holder created:', {
  id: accountHolder.id,
  mobile: accountHolder.mobile,
  name: accountHolder.name
});

// Step 2: Create NOK user
console.log('\n2️⃣ Creating NOK user...');
const nokUser = db.createUser({
  mobile: '+919876543210',
  name: 'Jane Smith',
  role: 'nok'
});
console.log('✅ NOK user created:', {
  id: nokUser.id,
  mobile: nokUser.mobile,
  name: nokUser.name
});

// Step 3: Simulate socket connection for NOK
console.log('\n3️⃣ Simulating NOK socket connection...');
const mockSocketId = 'socket-123-abc-456';
db.setSocketConnection(nokUser.id, mockSocketId);
console.log('✅ NOK socket connected:', {
  userId: nokUser.id,
  socketId: mockSocketId
});

// Step 4: Verify socket connection lookup
console.log('\n4️⃣ Verifying socket connection lookup...');
const retrievedSocketId = db.getSocketConnection(nokUser.id);
console.log('Socket ID retrieved:', retrievedSocketId);
console.log(retrievedSocketId === mockSocketId ? '✅ Socket lookup works!' : '❌ Socket lookup failed!');

// Step 5: Test getUserByMobile
console.log('\n5️⃣ Testing getUserByMobile...');
const foundNokUser = db.getUserByMobile(nokUser.mobile);
console.log('User found:', foundNokUser ? 'YES' : 'NO');
if (foundNokUser) {
  console.log('✅ getUserByMobile works:', {
    id: foundNokUser.id,
    mobile: foundNokUser.mobile
  });
} else {
  console.log('❌ getUserByMobile failed!');
}

// Step 6: Create designation
console.log('\n6️⃣ Creating NOK designation...');
const designation = db.createNOKDesignation(accountHolder.id, {
  nokMobile: nokUser.mobile,
  nokName: nokUser.name,
  relationship: 'spouse'
});
console.log('✅ Designation created:', {
  id: designation.id,
  accountHolderName: designation.accountHolderName,
  nokMobile: designation.nokMobile,
  nokName: designation.nokName,
  relationship: designation.relationship
});

// Step 7: Simulate the backend route logic
console.log('\n7️⃣ Simulating backend route logic...');
console.log('🔍 Looking up NOK user by mobile:', designation.nokMobile);
const nokUserFromDb = db.getUserByMobile(designation.nokMobile);
let nokSocketIdFromDb = null;

if (nokUserFromDb) {
  console.log('✅ NOK user found:', nokUserFromDb.id);

  nokSocketIdFromDb = db.getSocketConnection(nokUserFromDb.id);
  console.log('🔍 Socket ID for NOK:', nokSocketIdFromDb);

  if (nokSocketIdFromDb) {
    console.log('✅ Socket found! Would emit to:', nokSocketIdFromDb);

    const eventData = {
      designationId: designation.id,
      accountHolderId: designation.accountHolderId,
      accountHolderName: designation.accountHolderName,
      accountHolderMobile: designation.accountHolderMobile,
      relationship: designation.relationship,
      designatedAt: designation.designatedAt,
      message: `${designation.accountHolderName} has designated you as their ${designation.relationship}`
    };

    console.log('📤 Event data to be sent:', JSON.stringify(eventData, null, 2));
    console.log('\n✅ Backend logic test PASSED!');
  } else {
    console.log('❌ Socket not found!');
  }
} else {
  console.log('❌ NOK user not found!');
}

// Summary
console.log('\n' + '='.repeat(50));
console.log('📊 Test Summary:');
console.log('  - Account holder created: ✅');
console.log('  - NOK user created: ✅');
console.log('  - Socket connection stored: ✅');
console.log('  - Socket lookup works: ' + (retrievedSocketId === mockSocketId ? '✅' : '❌'));
console.log('  - getUserByMobile works: ' + (foundNokUser ? '✅' : '❌'));
console.log('  - Designation created: ✅');
console.log('  - Full flow simulation: ' + (nokUserFromDb && nokSocketIdFromDb ? '✅' : '❌'));
console.log('='.repeat(50) + '\n');

// Cleanup
console.log('🧹 Cleaning up test data...');
db.clearAll();
console.log('✅ Test data cleared\n');
