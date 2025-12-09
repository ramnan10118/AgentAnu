import express from 'express';
import db from '../models/index.js';
import { fetchAssets, getAssetStats } from '../services/mockAnumati.js';
import { authenticate } from '../middleware/auth.js';
import { v4 as uuidv4 } from 'uuid';

const router = express.Router();

/**
 * POST /api/assets/consent
 * User gives consent to fetch assets via Anumati
 */
router.post('/consent', authenticate, (req, res) => {
  try {
    const { consented } = req.body;

    if (consented !== true) {
      return res.status(400).json({
        success: false,
        message: 'User consent is required'
      });
    }

    // Update user consent
    const updatedUser = db.updateUser(req.user.id, {
      consentedAnumati: true
    });

    res.json({
      success: true,
      message: 'Consent recorded successfully',
      user: {
        id: updatedUser.id,
        consentedAnumati: updatedUser.consentedAnumati
      }
    });
  } catch (error) {
    console.error('Consent error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to record consent'
    });
  }
});

/**
 * GET /api/assets/fetch
 * Fetch assets from mock Anumati
 */
router.get('/fetch', authenticate, async (req, res) => {
  try {
    if (!req.user.consentedAnumati) {
      return res.status(400).json({
        success: false,
        message: 'User consent is required'
      });
    }

    // Use provided PAN or default to first sample PAN for demo purposes
    const panToUse = req.user.pan || 'ABCDE1234F';

    // Fetch assets from mock Anumati
    const result = await fetchAssets(panToUse, req.user.id);

    // Update user name if we got it from Anumati
    if (result.name && !req.user.name) {
      db.updateUser(req.user.id, { name: result.name });
    }

    // Store assets
    db.setAssets(req.user.id, result.assets);

    res.json({
      success: true,
      message: 'Assets fetched successfully',
      assets: result.assets,
      totalNetWorth: result.totalNetWorth,
      stats: getAssetStats(result.assets)
    });
  } catch (error) {
    console.error('Fetch assets error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch assets'
    });
  }
});

/**
 * GET /api/assets
 * Get user's stored assets
 */
router.get('/', authenticate, (req, res) => {
  try {
    const assets = db.getAssets(req.user.id);

    const totalNetWorth = assets.reduce((sum, asset) => sum + asset.value, 0);

    res.json({
      success: true,
      assets,
      totalNetWorth,
      stats: getAssetStats(assets)
    });
  } catch (error) {
    console.error('Get assets error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get assets'
    });
  }
});

/**
 * POST /api/assets/manual
 * Add a manually uploaded asset to user's portfolio
 */
router.post('/manual', authenticate, (req, res) => {
  try {
    const { type, name, location, value, provider, accountNumber, details } = req.body;

    if (!type || !name || value === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Type, name, and value are required'
      });
    }

    // Create new asset
    const newAsset = {
      id: uuidv4(),
      userId: req.user.id,
      type: type === 'Property' ? 'property' : type === 'Land' ? 'real_estate' : type === 'Vehicle' ? 'vehicle' : 'other',
      provider: provider || name,
      accountNumber: accountNumber || 'N/A',
      value: parseFloat(value),
      currency: 'INR',
      details: {
        ...details,
        location: location,
        name: name,
        source: 'manual_upload',
      },
      source: 'manual_upload',
      asOf: new Date().toISOString(),
      isRevealed: false,
    };

    // Add asset to user's portfolio
    const currentAssets = db.getAssets(req.user.id);
    const updatedAssets = [...currentAssets, newAsset];
    db.setAssets(req.user.id, updatedAssets);

    const totalNetWorth = updatedAssets.reduce((sum, asset) => sum + asset.value, 0);

    res.json({
      success: true,
      message: 'Asset added successfully',
      asset: newAsset,
      totalNetWorth,
      stats: getAssetStats(updatedAssets)
    });
  } catch (error) {
    console.error('Add manual asset error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to add asset'
    });
  }
});

/**
 * GET /api/assets/revealed/:userId
 * Get revealed assets (for NOK after death verification)
 */
router.get('/revealed/:userId', authenticate, (req, res) => {
  try {
    const { userId } = req.params;

    // Check if death certificate is verified
    const deathCert = db.getDeathCertificate(userId);

    if (!deathCert || deathCert.status !== 'verified') {
      return res.status(403).json({
        success: false,
        message: 'Assets can only be revealed after death certificate verification'
      });
    }

    // Check if current user is the NOK
    const designation = db.getNOKDesignationByUserId(userId);

    if (!designation || designation.nokId !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Only designated NOK can access revealed assets'
      });
    }

    // Get assets and mark as revealed
    const assets = db.getAssets(userId);
    const revealedAssets = assets.map(asset => ({
      ...asset,
      isRevealed: true
    }));

    const totalNetWorth = revealedAssets.reduce((sum, asset) => sum + asset.value, 0);

    // Get account holder info
    const accountHolder = db.getUserById(userId);

    res.json({
      success: true,
      accountHolder: {
        name: accountHolder?.name,
        pan: accountHolder?.pan
      },
      assets: revealedAssets,
      totalNetWorth,
      stats: getAssetStats(revealedAssets)
    });
  } catch (error) {
    console.error('Get revealed assets error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get revealed assets'
    });
  }
});

export default router;
