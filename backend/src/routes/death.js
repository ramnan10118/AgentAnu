import express from 'express';
import db from '../models/index.js';
import { createYellowHandoff, getClaimsGuidance } from '../services/mockYellow.js';
import { authenticate } from '../middleware/auth.js';
import dotenv from 'dotenv';

dotenv.config();

const router = express.Router();

/**
 * POST /api/death/upload-certificate
 * NOK uploads death certificate
 */
router.post('/upload-certificate', authenticate, async (req, res) => {
  try {
    const { accountHolderMobile, fileName, fileData } = req.body;

    if (!accountHolderMobile || !fileName || !fileData) {
      return res.status(400).json({
        success: false,
        message: 'Account holder mobile, file name, and file data are required'
      });
    }

    // Find account holder by mobile
    const accountHolder = db.getUserByMobile(accountHolderMobile);

    if (!accountHolder) {
      return res.status(404).json({
        success: false,
        message: 'Account holder not found'
      });
    }

    // Check if current user is the designated NOK
    const designation = db.getNOKDesignationByUserId(accountHolder.id);

    if (!designation || designation.nokMobile !== req.user.mobile) {
      return res.status(403).json({
        success: false,
        message: 'You are not authorized to upload death certificate for this user'
      });
    }

    if (designation.status !== 'accepted') {
      return res.status(400).json({
        success: false,
        message: 'Designation must be accepted before uploading death certificate'
      });
    }

    // Create death certificate
    const deathCert = db.createDeathCertificate({
      userId: accountHolder.id,
      nokId: req.user.id,
      fileName,
      fileData // base64 encoded
    });

    // Auto-verify if enabled (for hackathon)
    if (process.env.AUTO_VERIFY_DEATH_CERT === 'true') {
      const verificationDelay = parseInt(process.env.VERIFICATION_DELAY_MS) || 5000;

      setTimeout(() => {
        db.verifyDeathCertificate(accountHolder.id, 'auto-admin');
        console.log(`✅ Auto-verified death certificate for user ${accountHolder.id}`);
      }, verificationDelay);
    }

    res.json({
      success: true,
      message: 'Death certificate uploaded successfully',
      certificate: {
        id: deathCert.id,
        fileName: deathCert.fileName,
        uploadedAt: deathCert.uploadedAt,
        status: deathCert.status
      }
    });
  } catch (error) {
    console.error('Upload death certificate error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to upload death certificate'
    });
  }
});

/**
 * GET /api/death/status/:accountHolderId
 * Check death certificate verification status
 */
router.get('/status/:accountHolderId', authenticate, (req, res) => {
  try {
    const { accountHolderId } = req.params;

    // Check if current user is NOK
    const designation = db.getNOKDesignationByUserId(accountHolderId);

    if (!designation || designation.nokMobile !== req.user.mobile) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized'
      });
    }

    const deathCert = db.getDeathCertificate(accountHolderId);

    if (!deathCert) {
      return res.json({
        success: true,
        uploaded: false,
        status: null
      });
    }

    res.json({
      success: true,
      uploaded: true,
      certificate: {
        id: deathCert.id,
        fileName: deathCert.fileName,
        uploadedAt: deathCert.uploadedAt,
        status: deathCert.status,
        verifiedAt: deathCert.verifiedAt,
        rejectionReason: deathCert.rejectionReason
      }
    });
  } catch (error) {
    console.error('Get death status error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get death certificate status'
    });
  }
});

/**
 * POST /api/death/verify/:userId
 * Manually verify death certificate (admin)
 */
router.post('/verify/:userId', authenticate, (req, res) => {
  try {
    const { userId } = req.params;

    // In a real app, this would have admin authentication
    // For hackathon, any authenticated user can verify (for testing)

    const deathCert = db.getDeathCertificate(userId);

    if (!deathCert) {
      return res.status(404).json({
        success: false,
        message: 'Death certificate not found'
      });
    }

    if (deathCert.status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: `Certificate is already ${deathCert.status}`
      });
    }

    const verified = db.verifyDeathCertificate(userId, req.user.id);

    res.json({
      success: true,
      message: 'Death certificate verified successfully',
      certificate: {
        id: verified.id,
        status: verified.status,
        verifiedAt: verified.verifiedAt
      }
    });
  } catch (error) {
    console.error('Verify death certificate error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to verify death certificate'
    });
  }
});

/**
 * POST /api/death/yellow-handoff
 * Create Yellow handoff for claims assistance
 */
router.post('/yellow-handoff', authenticate, async (req, res) => {
  try {
    const { accountHolderId } = req.body;

    if (!accountHolderId) {
      return res.status(400).json({
        success: false,
        message: 'Account holder ID is required'
      });
    }

    // Check if current user is NOK
    const designation = db.getNOKDesignationByUserId(accountHolderId);

    if (!designation || designation.nokId !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized'
      });
    }

    // Check if death certificate is verified
    const deathCert = db.getDeathCertificate(accountHolderId);

    if (!deathCert || deathCert.status !== 'verified') {
      return res.status(400).json({
        success: false,
        message: 'Death certificate must be verified first'
      });
    }

    // Get assets
    const assets = db.getAssets(accountHolderId);

    // Create Yellow handoff
    const handoff = await createYellowHandoff(
      {
        name: req.user.name || 'NOK',
        mobile: req.user.mobile
      },
      assets
    );

    res.json({
      success: true,
      message: 'Yellow handoff created successfully',
      handoff
    });
  } catch (error) {
    console.error('Yellow handoff error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create Yellow handoff'
    });
  }
});

/**
 * GET /api/death/claims-guidance/:assetType
 * Get claims guidance for specific asset type
 */
router.get('/claims-guidance/:assetType', authenticate, (req, res) => {
  try {
    const { assetType } = req.params;

    const guidance = getClaimsGuidance(assetType);

    res.json({
      success: true,
      assetType,
      guidance
    });
  } catch (error) {
    console.error('Get claims guidance error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get claims guidance'
    });
  }
});

export default router;
