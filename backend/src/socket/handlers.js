import db from '../models/index.js';

/**
 * Socket.io Event Handlers
 * Handles real-time communication for NOK designation and death verification
 */

export const setupSocketHandlers = (io) => {
  io.on('connection', (socket) => {
    console.log(`🔌 Socket connected: ${socket.id}`);

    /**
     * Client authenticates with token
     */
    socket.on('authenticate', (data) => {
      try {
        const { token } = data;

        if (!token) {
          socket.emit('error', { message: 'Token required for authentication' });
          return;
        }

        const user = db.getUserBySession(token);

        if (!user) {
          socket.emit('error', { message: 'Invalid token' });
          return;
        }

        // Store user info in socket
        socket.userId = user.id;
        socket.userMobile = user.mobile;

        // Store socket connection
        db.setSocketConnection(user.id, socket.id);

        socket.emit('authenticated', {
          userId: user.id,
          mobile: user.mobile
        });

        console.log(`✅ Socket authenticated: ${socket.id} -> User: ${user.id}`);

        // Check for pending designations (if NOK)
        const designations = db.getNOKDesignationsByMobile(user.mobile);
        const pendingDesignations = designations.filter(d => d.status === 'pending');

        if (pendingDesignations.length > 0) {
          pendingDesignations.forEach(designation => {
            socket.emit('nok:designated', {
              designationId: designation.id,
              accountHolderId: designation.accountHolderId,
              accountHolderName: designation.accountHolderName,
              relationship: designation.relationship,
              designatedAt: designation.designatedAt
            });
          });
        }

        // Check for death certificate verification (if NOK)
        // This is for when NOK reconnects after uploading
        const nokDesignations = db.getNOKDesignationsByMobile(user.mobile);
        nokDesignations.forEach(designation => {
          if (designation.status === 'accepted') {
            const deathCert = db.getDeathCertificate(designation.accountHolderId);
            if (deathCert && deathCert.status === 'verified') {
              socket.emit('death:verified', {
                accountHolderId: designation.accountHolderId,
                verifiedAt: deathCert.verifiedAt
              });
            }
          }
        });
      } catch (error) {
        console.error('Authentication error:', error);
        socket.emit('error', { message: 'Authentication failed' });
      }
    });

    /**
     * Account holder designates NOK (triggered after API call)
     */
    socket.on('nok:designate', (data) => {
      try {
        const { designationId } = data;

        const designation = db.getNOKDesignation(designationId);

        if (!designation) {
          socket.emit('error', { message: 'Designation not found' });
          return;
        }

        console.log(`👤 NOK designation event: ${designationId} for NOK: ${designation.nokMobile}`);

        // Send notification to NOK if they're connected
        // We find NOK by mobile number
        const nokUser = db.getUserByMobile(designation.nokMobile);

        if (nokUser) {
          const nokSocketId = db.getSocketConnection(nokUser.id);

          if (nokSocketId) {
            io.to(nokSocketId).emit('nok:designated', {
              designationId: designation.id,
              accountHolderId: designation.accountHolderId,
              accountHolderName: designation.accountHolderName,
              relationship: designation.relationship,
              designatedAt: designation.designatedAt
            });

            console.log(`📤 Sent designation notification to NOK socket: ${nokSocketId}`);
          } else {
            console.log(`⚠️ NOK not connected, will receive notification on next login`);
          }
        }

        socket.emit('nok:designate:success', {
          designationId: designation.id,
          status: designation.status
        });
      } catch (error) {
        console.error('Designate NOK error:', error);
        socket.emit('error', { message: 'Failed to designate NOK' });
      }
    });

    /**
     * NOK accepts designation (triggered after API call)
     */
    socket.on('nok:accept', (data) => {
      try {
        const { designationId } = data;

        const designation = db.getNOKDesignation(designationId);

        if (!designation) {
          socket.emit('error', { message: 'Designation not found' });
          return;
        }

        if (designation.status !== 'accepted') {
          socket.emit('error', { message: 'Designation not accepted yet' });
          return;
        }

        console.log(`✅ NOK accepted event: ${designationId}`);

        // Send notification to account holder
        const accountHolderSocketId = db.getSocketConnection(designation.accountHolderId);

        if (accountHolderSocketId) {
          io.to(accountHolderSocketId).emit('nok:accepted', {
            designationId: designation.id,
            nokName: designation.nokName,
            nokMobile: designation.nokMobile,
            acceptedAt: designation.respondedAt
          });

          console.log(`📤 Sent acceptance notification to account holder socket: ${accountHolderSocketId}`);
        }

        socket.emit('nok:accept:success', {
          designationId: designation.id,
          status: designation.status
        });
      } catch (error) {
        console.error('Accept NOK error:', error);
        socket.emit('error', { message: 'Failed to accept designation' });
      }
    });

    /**
     * NOK rejects designation
     */
    socket.on('nok:reject', (data) => {
      try {
        const { designationId } = data;

        const designation = db.getNOKDesignation(designationId);

        if (!designation) {
          socket.emit('error', { message: 'Designation not found' });
          return;
        }

        console.log(`❌ NOK rejected event: ${designationId}`);

        // Send notification to account holder
        const accountHolderSocketId = db.getSocketConnection(designation.accountHolderId);

        if (accountHolderSocketId) {
          io.to(accountHolderSocketId).emit('nok:rejected', {
            designationId: designation.id,
            nokName: designation.nokName,
            rejectedAt: designation.respondedAt,
            reason: designation.rejectionReason
          });

          console.log(`📤 Sent rejection notification to account holder socket: ${accountHolderSocketId}`);
        }

        socket.emit('nok:reject:success', {
          designationId: designation.id,
          status: designation.status
        });
      } catch (error) {
        console.error('Reject NOK error:', error);
        socket.emit('error', { message: 'Failed to reject designation' });
      }
    });

    /**
     * Death certificate uploaded
     */
    socket.on('death:certificate:uploaded', (data) => {
      try {
        const { accountHolderId } = data;

        console.log(`📄 Death certificate uploaded for user: ${accountHolderId}`);

        // This is mainly for logging/admin notification
        // Verification happens in the API route

        socket.emit('death:certificate:uploaded:success', {
          accountHolderId,
          message: 'Certificate uploaded and pending verification'
        });
      } catch (error) {
        console.error('Death certificate upload event error:', error);
        socket.emit('error', { message: 'Failed to process upload event' });
      }
    });

    /**
     * Death certificate verified (called after verification)
     */
    socket.on('death:verified:notify', (data) => {
      try {
        const { accountHolderId } = data;

        const deathCert = db.getDeathCertificate(accountHolderId);

        if (!deathCert || deathCert.status !== 'verified') {
          return;
        }

        console.log(`✅ Death verified event for user: ${accountHolderId}`);

        // Send notification to NOK
        const nokSocketId = db.getSocketConnection(deathCert.nokId);

        if (nokSocketId) {
          io.to(nokSocketId).emit('death:verified', {
            accountHolderId,
            verifiedAt: deathCert.verifiedAt
          });

          console.log(`📤 Sent verification notification to NOK socket: ${nokSocketId}`);
        }
      } catch (error) {
        console.error('Death verified event error:', error);
      }
    });

    /**
     * Generic notification
     */
    socket.on('notification:send', (data) => {
      try {
        const { targetUserId, type, title, message } = data;

        const targetSocketId = db.getSocketConnection(targetUserId);

        if (targetSocketId) {
          io.to(targetSocketId).emit('notification:new', {
            type,
            title,
            message,
            timestamp: new Date().toISOString()
          });
        }
      } catch (error) {
        console.error('Send notification error:', error);
      }
    });

    /**
     * Disconnect
     */
    socket.on('disconnect', () => {
      console.log(`🔌 Socket disconnected: ${socket.id}`);

      if (socket.userId) {
        db.removeSocketConnection(socket.userId);
      }
    });
  });

  // Background job to auto-notify NOK when death certificate is verified
  // This is triggered by the timeout in the death route
  setInterval(() => {
    // Check for newly verified death certificates
    // In a real app, this would be event-driven
    // For hackathon, we handle this in the API route's setTimeout
  }, 10000);
};

/**
 * Helper function to notify NOK of death verification
 * Can be called from API routes
 */
export const notifyDeathVerification = (io, accountHolderId) => {
  try {
    const deathCert = db.getDeathCertificate(accountHolderId);

    if (!deathCert || deathCert.status !== 'verified') {
      return;
    }

    const nokSocketId = db.getSocketConnection(deathCert.nokId);

    if (nokSocketId) {
      io.to(nokSocketId).emit('death:verified', {
        accountHolderId,
        verifiedAt: deathCert.verifiedAt
      });

      console.log(`📤 Notified NOK of death verification: ${nokSocketId}`);
    }
  } catch (error) {
    console.error('Notify death verification error:', error);
  }
};
