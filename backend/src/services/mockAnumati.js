import { v4 as uuidv4 } from 'uuid';

/**
 * Mock Anumati (Account Aggregator) Service
 * Provides fake asset data for demo purposes
 */

// Mock asset data by PAN
const MOCK_ASSETS_BY_PAN = {
  'ABCDE1234F': {
    name: 'Rajesh Kumar',
    assets: [
      {
        type: 'bank_account',
        provider: 'HDFC Bank',
        accountNumber: 'XXXX1234',
        value: 500000,
        currency: 'INR',
        details: {
          ifsc: 'HDFC0001234',
          accountType: 'Savings',
          branch: 'Mumbai Main'
        }
      },
      {
        type: 'bank_account',
        provider: 'ICICI Bank',
        accountNumber: 'XXXX5678',
        value: 250000,
        currency: 'INR',
        details: {
          ifsc: 'ICIC0001234',
          accountType: 'Current',
          branch: 'Bangalore'
        }
      },
      {
        type: 'mutual_fund',
        provider: 'Axis Mutual Fund',
        accountNumber: 'MF123456',
        value: 1200000,
        currency: 'INR',
        details: {
          fundName: 'Axis Bluechip Fund',
          units: 5432.12,
          nav: 220.85
        }
      },
      {
        type: 'mutual_fund',
        provider: 'HDFC Mutual Fund',
        accountNumber: 'MF789012',
        value: 800000,
        currency: 'INR',
        details: {
          fundName: 'HDFC Midcap Opportunities',
          units: 3210.45,
          nav: 249.20
        }
      },
      {
        type: 'insurance',
        provider: 'LIC',
        accountNumber: 'POL123456',
        value: 2000000,
        currency: 'INR',
        details: {
          policyNumber: 'POL123456',
          policyType: 'Term Insurance',
          maturityDate: '2030-12-31',
          sumAssured: 2000000
        }
      },
      {
        type: 'fd',
        provider: 'SBI',
        accountNumber: 'FD987654',
        value: 500000,
        currency: 'INR',
        details: {
          maturityDate: '2026-06-15',
          interestRate: 6.5,
          tenure: '5 years'
        }
      },
      {
        type: 'nps',
        provider: 'NPS Trust',
        accountNumber: 'NPS123456789012',
        value: 350000,
        currency: 'INR',
        details: {
          pranNumber: 'NPS123456789012',
          pensionFundManager: 'HDFC Pension'
        }
      },
      {
        type: 'securities',
        provider: 'Zerodha',
        accountNumber: 'DEMAT123',
        value: 1500000,
        currency: 'INR',
        details: {
          dpId: 'IN300123',
          clientId: '12345678',
          holdings: 'Multiple stocks and ETFs'
        }
      }
    ]
  },
  'XYZAB5678C': {
    name: 'Priya Sharma',
    assets: [
      {
        type: 'bank_account',
        provider: 'SBI',
        accountNumber: 'XXXX9012',
        value: 800000,
        currency: 'INR',
        details: {
          ifsc: 'SBIN0001234',
          accountType: 'Savings',
          branch: 'Delhi'
        }
      },
      {
        type: 'mutual_fund',
        provider: 'ICICI Prudential',
        accountNumber: 'MF345678',
        value: 1500000,
        currency: 'INR',
        details: {
          fundName: 'ICICI Prudential Bluechip Fund',
          units: 6789.45,
          nav: 220.95
        }
      },
      {
        type: 'insurance',
        provider: 'Max Life',
        accountNumber: 'POL789012',
        value: 1000000,
        currency: 'INR',
        details: {
          policyNumber: 'POL789012',
          policyType: 'ULIP',
          maturityDate: '2035-03-20',
          sumAssured: 1000000
        }
      },
      {
        type: 'nps',
        provider: 'NPS Trust',
        accountNumber: 'NPS987654321098',
        value: 200000,
        currency: 'INR',
        details: {
          pranNumber: 'NPS987654321098',
          pensionFundManager: 'SBI Pension'
        }
      }
    ]
  },
  'PQRST9012G': {
    name: 'Amit Patel',
    assets: [
      {
        type: 'bank_account',
        provider: 'Axis Bank',
        accountNumber: 'XXXX3456',
        value: 350000,
        currency: 'INR',
        details: {
          ifsc: 'UTIB0001234',
          accountType: 'Savings',
          branch: 'Ahmedabad'
        }
      },
      {
        type: 'mutual_fund',
        provider: 'SBI Mutual Fund',
        accountNumber: 'MF567890',
        value: 950000,
        currency: 'INR',
        details: {
          fundName: 'SBI Large Cap Fund',
          units: 4321.67,
          nav: 219.80
        }
      },
      {
        type: 'fd',
        provider: 'HDFC Bank',
        accountNumber: 'FD234567',
        value: 600000,
        currency: 'INR',
        details: {
          maturityDate: '2027-09-10',
          interestRate: 6.75,
          tenure: '3 years'
        }
      }
    ]
  }
};

/**
 * Validate PAN format
 */
export const validatePAN = (pan) => {
  const panRegex = /^[A-Z]{5}[0-9]{4}[A-Z]$/;

  if (!panRegex.test(pan)) {
    return {
      valid: false,
      message: 'Invalid PAN format. Expected format: ABCDE1234F'
    };
  }

  return {
    valid: true,
    message: 'PAN validated successfully'
  };
};

/**
 * Fetch assets for a PAN from mock Anumati
 */
export const fetchAssets = async (pan, userId) => {
  console.log(`🏦 Fetching mock Anumati assets for PAN: ${pan}`);

  // Simulate API delay
  await new Promise(resolve => setTimeout(resolve, 1500));

  const mockData = MOCK_ASSETS_BY_PAN[pan];

  if (!mockData) {
    // Return default smaller portfolio for unknown PANs
    return {
      name: 'Demo User',
      assets: [
        {
          id: uuidv4(),
          userId,
          type: 'bank_account',
          provider: 'HDFC Bank',
          accountNumber: 'XXXX1111',
          value: 100000,
          currency: 'INR',
          details: {
            ifsc: 'HDFC0001111',
            accountType: 'Savings',
            branch: 'Branch'
          },
          source: 'anumati',
          asOf: new Date().toISOString(),
          isRevealed: false
        }
      ],
      totalNetWorth: 100000
    };
  }

  // Add IDs and metadata to assets
  const assetsWithMetadata = mockData.assets.map(asset => ({
    id: uuidv4(),
    userId,
    ...asset,
    source: 'anumati',
    asOf: new Date().toISOString(),
    isRevealed: false
  }));

  const totalNetWorth = assetsWithMetadata.reduce((sum, asset) => sum + asset.value, 0);

  return {
    name: mockData.name,
    assets: assetsWithMetadata,
    totalNetWorth
  };
};

/**
 * Get asset statistics
 */
export const getAssetStats = (assets) => {
  const stats = {
    total: assets.length,
    byType: {},
    totalValue: 0
  };

  assets.forEach(asset => {
    stats.totalValue += asset.value;

    if (!stats.byType[asset.type]) {
      stats.byType[asset.type] = {
        count: 0,
        totalValue: 0
      };
    }

    stats.byType[asset.type].count++;
    stats.byType[asset.type].totalValue += asset.value;
  });

  return stats;
};
