import express from 'express';
import db from '../models/index.js';
import { sendOTP, generateOTP } from '../services/mockOTP.js';
import { validatePAN } from '../services/mockAnumati.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

/**
 * POST /api/auth/send-otp
 * Send OTP to mobile number
 */
router.post('/send-otp', (req, res) => {
  try {
    const { mobile } = req.body;

    if (!mobile) {
      return res.status(400).json({
        success: false,
        message: 'Mobile number is required'
      });
    }

    // Validate mobile format (basic)
    const mobileRegex = /^[+]?[0-9]{10,15}$/;
    if (!mobileRegex.test(mobile)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid mobile number format'
      });
    }

    // Generate and store OTP
    const otp = generateOTP();
    db.storeOTP(mobile, otp);

    // Send OTP (mock)
    const otpResult = sendOTP(mobile);

    res.json({
      success: true,
      message: 'OTP sent successfully',
      // Only for hackathon demo!
      otp: otpResult.otp
    });
  } catch (error) {
    console.error('Send OTP error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send OTP'
    });
  }
});

/**
 * POST /api/auth/verify-otp
 * Verify OTP and create/login user
 */
router.post('/verify-otp', (req, res) => {
  try {
    const { mobile, otp } = req.body;

    if (!mobile || !otp) {
      return res.status(400).json({
        success: false,
        message: 'Mobile and OTP are required'
      });
    }

    // Verify OTP
    const isValid = db.verifyOTP(mobile, otp);

    if (!isValid) {
      return res.status(401).json({
        success: false,
        message: 'Invalid or expired OTP'
      });
    }

    // Check if user exists
    let user = db.getUserByMobile(mobile);

    if (!user) {
      // Create new user
      user = db.createUser({
        mobile,
        role: 'account_holder'
      });
    }

    // Create session
    const token = db.createSession(user.id);

    res.json({
      success: true,
      message: 'OTP verified successfully',
      token,
      user: {
        id: user.id,
        mobile: user.mobile,
        name: user.name,
        role: user.role,
        pan: user.pan,
        consentedAnumati: user.consentedAnumati,
        nokDesignationId: user.nokDesignationId
      }
    });
  } catch (error) {
    console.error('Verify OTP error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to verify OTP'
    });
  }
});

/**
 * POST /api/auth/validate-pan
 * Validate PAN and fetch name
 */
router.post('/validate-pan', authenticate, (req, res) => {
  try {
    const { pan } = req.body;

    if (!pan) {
      return res.status(400).json({
        success: false,
        message: 'PAN is required'
      });
    }

    const validation = validatePAN(pan);

    if (!validation.valid) {
      return res.status(400).json({
        success: false,
        message: validation.message
      });
    }

    // Update user with PAN
    const updatedUser = db.updateUser(req.user.id, { pan });

    res.json({
      success: true,
      message: 'PAN validated successfully',
      user: {
        id: updatedUser.id,
        mobile: updatedUser.mobile,
        name: updatedUser.name,
        pan: updatedUser.pan,
        role: updatedUser.role
      }
    });
  } catch (error) {
    console.error('Validate PAN error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to validate PAN'
    });
  }
});

/**
 * GET /api/auth/me
 * Get current user info
 */
router.get('/me', authenticate, (req, res) => {
  try {
    res.json({
      success: true,
      user: {
        id: req.user.id,
        mobile: req.user.mobile,
        name: req.user.name,
        email: req.user.email,
        pan: req.user.pan,
        role: req.user.role,
        consentedAnumati: req.user.consentedAnumati,
        nokDesignationId: req.user.nokDesignationId
      }
    });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get user info'
    });
  }
});

/**
 * POST /api/auth/logout
 * Logout user (delete session)
 */
router.post('/logout', authenticate, (req, res) => {
  try {
    db.deleteSession(req.token);

    res.json({
      success: true,
      message: 'Logged out successfully'
    });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to logout'
    });
  }
});

export default router;
