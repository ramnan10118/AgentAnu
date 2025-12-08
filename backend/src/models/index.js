import { v4 as uuidv4 } from 'uuid';

/**
 * In-Memory Database for Sunset Hackathon
 * All data resets on server restart
 */
class InMemoryDatabase {
  constructor() {
    // User storage: userId -> User object
    this.users = new Map();

    // Session storage: sessionToken -> userId
    this.sessions = new Map();

    // NOK designation storage: designationId -> NOKDesignation object
    this.nokDesignations = new Map();

    // User to NOK designation mapping: userId -> designationId
    this.userToNOKDesignation = new Map();

    // NOK mobile to designations: mobile -> [designationIds]
    this.nokMobileToDesignations = new Map();

    // Assets storage: userId -> Asset[]
    this.assets = new Map();

    // Death certificates: userId -> DeathCertificate object
    this.deathCertificates = new Map();

    // OTP storage (temporary): mobile -> {otp, expiresAt}
    this.otpStore = new Map();

    // Socket connections: userId -> socketId
    this.socketConnections = new Map();
  }

  // User methods
  createUser(userData) {
    const userId = uuidv4();
    const user = {
      id: userId,
      mobile: userData.mobile,
      pan: userData.pan || null,
      name: userData.name || null,
      email: userData.email || null,
      role: userData.role || 'account_holder',
      createdAt: new Date().toISOString(),
      consentedAnumati: false,
      nokDesignationId: null
    };
    this.users.set(userId, user);
    return user;
  }

  getUserById(userId) {
    return this.users.get(userId);
  }

  getUserByMobile(mobile) {
    for (const user of this.users.values()) {
      if (user.mobile === mobile) {
        return user;
      }
    }
    return null;
  }

  updateUser(userId, updates) {
    const user = this.users.get(userId);
    if (!user) return null;

    Object.assign(user, updates);
    this.users.set(userId, user);
    return user;
  }

  // Session methods
  createSession(userId) {
    const token = uuidv4();
    this.sessions.set(token, {
      userId,
      createdAt: new Date().toISOString(),
      expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString() // 24 hours
    });
    return token;
  }

  getUserBySession(token) {
    const session = this.sessions.get(token);
    if (!session) return null;

    // Check if expired
    if (new Date(session.expiresAt) < new Date()) {
      this.sessions.delete(token);
      return null;
    }

    return this.getUserById(session.userId);
  }

  deleteSession(token) {
    this.sessions.delete(token);
  }

  // OTP methods
  storeOTP(mobile, otp) {
    this.otpStore.set(mobile, {
      otp,
      expiresAt: new Date(Date.now() + 10 * 60 * 1000).toISOString() // 10 minutes
    });
  }

  verifyOTP(mobile, otp) {
    const stored = this.otpStore.get(mobile);
    if (!stored) return false;

    // Check if expired
    if (new Date(stored.expiresAt) < new Date()) {
      this.otpStore.delete(mobile);
      return false;
    }

    if (stored.otp === otp) {
      this.otpStore.delete(mobile);
      return true;
    }

    return false;
  }

  // NOK Designation methods
  createNOKDesignation(accountHolderId, nokData) {
    const designationId = uuidv4();
    const accountHolder = this.getUserById(accountHolderId);

    const designation = {
      id: designationId,
      accountHolderId,
      accountHolderName: accountHolder.name,
      accountHolderMobile: accountHolder.mobile,
      nokMobile: nokData.nokMobile,
      nokName: nokData.nokName,
      nokId: null, // Set when NOK registers
      relationship: nokData.relationship,
      status: 'pending', // pending, accepted, rejected
      designatedAt: new Date().toISOString(),
      respondedAt: null
    };

    this.nokDesignations.set(designationId, designation);
    this.userToNOKDesignation.set(accountHolderId, designationId);

    // Add to NOK mobile mapping
    const existingDesignations = this.nokMobileToDesignations.get(nokData.nokMobile) || [];
    existingDesignations.push(designationId);
    this.nokMobileToDesignations.set(nokData.nokMobile, existingDesignations);

    // Update account holder
    this.updateUser(accountHolderId, { nokDesignationId: designationId });

    return designation;
  }

  getNOKDesignation(designationId) {
    return this.nokDesignations.get(designationId);
  }

  getNOKDesignationByUserId(userId) {
    const designationId = this.userToNOKDesignation.get(userId);
    if (!designationId) return null;
    return this.nokDesignations.get(designationId);
  }

  getNOKDesignationsByMobile(mobile) {
    const designationIds = this.nokMobileToDesignations.get(mobile) || [];
    return designationIds.map(id => this.nokDesignations.get(id)).filter(Boolean);
  }

  updateNOKDesignation(designationId, updates) {
    const designation = this.nokDesignations.get(designationId);
    if (!designation) return null;

    Object.assign(designation, updates);
    this.nokDesignations.set(designationId, designation);
    return designation;
  }

  acceptNOKDesignation(designationId, nokId) {
    const designation = this.nokDesignations.get(designationId);
    if (!designation) return null;

    designation.status = 'accepted';
    designation.nokId = nokId;
    designation.respondedAt = new Date().toISOString();

    this.nokDesignations.set(designationId, designation);
    return designation;
  }

  rejectNOKDesignation(designationId, nokId, reason) {
    const designation = this.nokDesignations.get(designationId);
    if (!designation) return null;

    designation.status = 'rejected';
    designation.nokId = nokId;
    designation.respondedAt = new Date().toISOString();
    designation.rejectionReason = reason;

    this.nokDesignations.set(designationId, designation);
    return designation;
  }

  // Assets methods
  setAssets(userId, assets) {
    this.assets.set(userId, assets);
  }

  getAssets(userId) {
    return this.assets.get(userId) || [];
  }

  // Death Certificate methods
  createDeathCertificate(data) {
    const certId = uuidv4();
    const deathCert = {
      id: certId,
      userId: data.userId,
      nokId: data.nokId,
      fileName: data.fileName,
      fileData: data.fileData, // base64
      uploadedAt: new Date().toISOString(),
      status: 'pending', // pending, verified, rejected
      verifiedAt: null,
      verifiedBy: null,
      rejectionReason: null
    };

    this.deathCertificates.set(data.userId, deathCert);
    return deathCert;
  }

  getDeathCertificate(userId) {
    return this.deathCertificates.get(userId);
  }

  verifyDeathCertificate(userId, verifiedBy) {
    const cert = this.deathCertificates.get(userId);
    if (!cert) return null;

    cert.status = 'verified';
    cert.verifiedAt = new Date().toISOString();
    cert.verifiedBy = verifiedBy || 'admin';

    this.deathCertificates.set(userId, cert);
    return cert;
  }

  rejectDeathCertificate(userId, reason) {
    const cert = this.deathCertificates.get(userId);
    if (!cert) return null;

    cert.status = 'rejected';
    cert.rejectionReason = reason;

    this.deathCertificates.set(userId, cert);
    return cert;
  }

  // Socket connection methods
  setSocketConnection(userId, socketId) {
    this.socketConnections.set(userId, socketId);
  }

  getSocketConnection(userId) {
    return this.socketConnections.get(userId);
  }

  removeSocketConnection(userId) {
    this.socketConnections.delete(userId);
  }

  getSocketByUserId(userId) {
    return this.socketConnections.get(userId);
  }

  // Debug methods (for development)
  getAllUsers() {
    return Array.from(this.users.values());
  }

  getAllDesignations() {
    return Array.from(this.nokDesignations.values());
  }

  clearAll() {
    this.users.clear();
    this.sessions.clear();
    this.nokDesignations.clear();
    this.userToNOKDesignation.clear();
    this.nokMobileToDesignations.clear();
    this.assets.clear();
    this.deathCertificates.clear();
    this.otpStore.clear();
    this.socketConnections.clear();
  }
}

// Export singleton instance
const db = new InMemoryDatabase();
export default db;
