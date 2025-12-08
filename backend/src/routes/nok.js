import express from 'express';
import db from '../models/index.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

/**
 * POST /api/nok/designate
 * Account holder designates a NOK
 */
router.post('/designate', authenticate, (req, res) => {
  try {
    const { nokMobile, nokName, relationship } = req.body;

    if (!nokMobile || !nokName || !relationship) {
      return res.status(400).json({
        success: false,
        message: 'NOK mobile, name, and relationship are required'
      });
    }

    // Validate relationship
    const validRelationships = ['spouse', 'child', 'parent', 'sibling', 'other'];
    if (!validRelationships.includes(relationship)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid relationship'
      });
    }

    // Check if user already has a NOK designation
    const existingDesignation = db.getNOKDesignationByUserId(req.user.id);
    if (existingDesignation && existingDesignation.status === 'accepted') {
      return res.status(400).json({
        success: false,
        message: 'You already have an accepted NOK designation'
      });
    }

    // Create NOK designation
    const designation = db.createNOKDesignation(req.user.id, {
      nokMobile,
      nokName,
      relationship
    });

    res.json({
      success: true,
      message: 'NOK designated successfully',
      designation: {
        id: designation.id,
        nokMobile: designation.nokMobile,
        nokName: designation.nokName,
        relationship: designation.relationship,
        status: designation.status,
        designatedAt: designation.designatedAt
      }
    });
  } catch (error) {
    console.error('Designate NOK error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to designate NOK'
    });
  }
});

/**
 * GET /api/nok/status
 * Get NOK designation status for account holder
 */
router.get('/status', authenticate, (req, res) => {
  try {
    const designation = db.getNOKDesignationByUserId(req.user.id);

    if (!designation) {
      return res.json({
        success: true,
        hasDesignation: false,
        designation: null
      });
    }

    res.json({
      success: true,
      hasDesignation: true,
      designation: {
        id: designation.id,
        nokMobile: designation.nokMobile,
        nokName: designation.nokName,
        relationship: designation.relationship,
        status: designation.status,
        designatedAt: designation.designatedAt,
        respondedAt: designation.respondedAt
      }
    });
  } catch (error) {
    console.error('Get NOK status error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get NOK status'
    });
  }
});

/**
 * GET /api/nok/designations
 * Get designations for NOK (by their mobile number)
 */
router.get('/designations', authenticate, (req, res) => {
  try {
    const designations = db.getNOKDesignationsByMobile(req.user.mobile);

    res.json({
      success: true,
      designations: designations.map(d => ({
        id: d.id,
        accountHolderId: d.accountHolderId,
        accountHolderName: d.accountHolderName,
        accountHolderMobile: d.accountHolderMobile,
        relationship: d.relationship,
        status: d.status,
        designatedAt: d.designatedAt,
        respondedAt: d.respondedAt
      }))
    });
  } catch (error) {
    console.error('Get designations error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get designations'
    });
  }
});

/**
 * POST /api/nok/accept/:designationId
 * NOK accepts designation
 */
router.post('/accept/:designationId', authenticate, (req, res) => {
  try {
    const { designationId } = req.params;

    const designation = db.getNOKDesignation(designationId);

    if (!designation) {
      return res.status(404).json({
        success: false,
        message: 'Designation not found'
      });
    }

    // Verify that the current user's mobile matches the NOK mobile
    if (designation.nokMobile !== req.user.mobile) {
      return res.status(403).json({
        success: false,
        message: 'You are not authorized to accept this designation'
      });
    }

    if (designation.status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: `Designation is already ${designation.status}`
      });
    }

    // Accept the designation
    const updatedDesignation = db.acceptNOKDesignation(designationId, req.user.id);

    res.json({
      success: true,
      message: 'Designation accepted successfully',
      designation: {
        id: updatedDesignation.id,
        accountHolderName: updatedDesignation.accountHolderName,
        status: updatedDesignation.status,
        respondedAt: updatedDesignation.respondedAt
      }
    });
  } catch (error) {
    console.error('Accept designation error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to accept designation'
    });
  }
});

/**
 * POST /api/nok/reject/:designationId
 * NOK rejects designation
 */
router.post('/reject/:designationId', authenticate, (req, res) => {
  try {
    const { designationId } = req.params;
    const { reason } = req.body;

    const designation = db.getNOKDesignation(designationId);

    if (!designation) {
      return res.status(404).json({
        success: false,
        message: 'Designation not found'
      });
    }

    // Verify that the current user's mobile matches the NOK mobile
    if (designation.nokMobile !== req.user.mobile) {
      return res.status(403).json({
        success: false,
        message: 'You are not authorized to reject this designation'
      });
    }

    if (designation.status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: `Designation is already ${designation.status}`
      });
    }

    // Reject the designation
    const updatedDesignation = db.rejectNOKDesignation(designationId, req.user.id, reason);

    res.json({
      success: true,
      message: 'Designation rejected',
      designation: {
        id: updatedDesignation.id,
        status: updatedDesignation.status,
        respondedAt: updatedDesignation.respondedAt
      }
    });
  } catch (error) {
    console.error('Reject designation error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to reject designation'
    });
  }
});

/**
 * DELETE /api/nok/revoke
 * Account holder revokes NOK designation
 */
router.delete('/revoke', authenticate, (req, res) => {
  try {
    const designation = db.getNOKDesignationByUserId(req.user.id);

    if (!designation) {
      return res.status(404).json({
        success: false,
        message: 'No designation found'
      });
    }

    // Update designation status to revoked (or could delete)
    db.updateNOKDesignation(designation.id, { status: 'revoked' });
    db.updateUser(req.user.id, { nokDesignationId: null });

    res.json({
      success: true,
      message: 'NOK designation revoked successfully'
    });
  } catch (error) {
    console.error('Revoke NOK error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to revoke NOK designation'
    });
  }
});

export default router;
