import express from 'express';
import multer from 'multer';
import { authenticate } from '../middleware/auth.js';
import { v4 as uuidv4 } from 'uuid';

const router = express.Router();

// Configure multer for file uploads (memory storage)
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'application/pdf'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only JPEG, PNG, and PDF are allowed.'));
    }
  },
});

/**
 * POST /api/ocr/extract-asset
 * Extract asset information from uploaded document using OCR
 * 
 * Note: This is a mock implementation. In production, integrate with Tesseract.js
 * or a cloud OCR service like Google Vision API, AWS Textract, etc.
 */
router.post('/extract-asset', authenticate, upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No file uploaded'
      });
    }

    const file = req.file;
    console.log(`📄 OCR request for file: ${file.originalname}, type: ${file.mimetype}, size: ${file.size} bytes`);

    // Simulate OCR processing delay
    await new Promise(resolve => setTimeout(resolve, 2000));

    // Mock OCR extraction based on filename and file type
    // In production, this would use Tesseract.js or a cloud OCR service
    const mockExtractedData = extractAssetInfoMock(file.originalname, file.mimetype);

    res.json({
      success: true,
      message: 'Asset information extracted successfully',
      data: {
        ...mockExtractedData,
        fileName: file.originalname,
        fileType: file.mimetype,
        fileSize: file.size,
      }
    });
  } catch (error) {
    console.error('OCR extraction error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to extract asset information'
    });
  }
});

/**
 * Mock OCR extraction function
 * In production, replace with actual OCR using Tesseract.js or cloud service
 */
function extractAssetInfoMock(fileName, mimeType) {
  const fileNameLower = fileName.toLowerCase();
  
  // Determine asset type from filename
  let assetType = 'Other';
  let assetName = 'Asset';
  let location = null;
  let value = 0;

  // Property/Land detection
  if (fileNameLower.includes('property') || fileNameLower.includes('house') || 
      fileNameLower.includes('apartment') || fileNameLower.includes('flat') ||
      fileNameLower.includes('villa') || fileNameLower.includes('home')) {
    assetType = 'Property';
    assetName = 'Residential Property';
    value = Math.floor(Math.random() * 50000000) + 5000000; // ₹50L - ₹5Cr
    location = ['Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Chennai'][Math.floor(Math.random() * 5)];
  } else if (fileNameLower.includes('land') || fileNameLower.includes('plot') || 
             fileNameLower.includes('site')) {
    assetType = 'Land';
    assetName = 'Land/Plot';
    value = Math.floor(Math.random() * 20000000) + 2000000; // ₹20L - ₹2Cr
    location = ['Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Chennai'][Math.floor(Math.random() * 5)];
  } else if (fileNameLower.includes('car') || fileNameLower.includes('vehicle') || 
             fileNameLower.includes('automobile')) {
    assetType = 'Vehicle';
    assetName = 'Car';
    value = Math.floor(Math.random() * 2000000) + 500000; // ₹5L - ₹25L
  } else if (fileNameLower.includes('bike') || fileNameLower.includes('motorcycle') || 
             fileNameLower.includes('scooter')) {
    assetType = 'Vehicle';
    assetName = 'Two Wheeler';
    value = Math.floor(Math.random() * 200000) + 50000; // ₹50K - ₹2.5L
  } else {
    // Default to property if it's a registration document
    if (fileNameLower.includes('registration') || fileNameLower.includes('deed') || 
        fileNameLower.includes('sale')) {
      assetType = 'Property';
      assetName = 'Property';
      value = Math.floor(Math.random() * 50000000) + 5000000;
      location = ['Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Chennai'][Math.floor(Math.random() * 5)];
    }
  }

  return {
    type: assetType,
    name: assetName,
    location: location,
    value: value,
    source: 'manual_upload',
    uploadDate: new Date().toISOString(),
    // Mock OCR text (in production, this would be actual OCR output)
    ocrText: `Mock OCR text extracted from ${fileName}. This would contain actual document text in production.`
  };
}

export default router;

