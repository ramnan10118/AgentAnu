/**
 * Mock Yellow Claims Assistance Service
 * Simulates handoff to Yellow for professional claims help
 */

export const createYellowHandoff = async (nokData, assets) => {
  console.log(`💼 Creating Yellow handoff for NOK: ${nokData.name}`);

  // Simulate API delay
  await new Promise(resolve => setTimeout(resolve, 500));

  // In a real app, this would call Yellow's API
  // For hackathon, we just return a mock response

  const totalAssetValue = assets.reduce((sum, asset) => sum + asset.value, 0);

  return {
    success: true,
    handoffId: `YEL-${Date.now()}`,
    message: 'Successfully connected with Yellow',
    estimatedFee: Math.round(totalAssetValue * 0.02), // 2% of total value
    contactNumber: '+91-1800-YELLOW',
    email: 'support@yellow.com',
    nextSteps: [
      'Yellow representative will contact you within 24 hours',
      'Keep all asset documents ready',
      'Prepare death certificate and legal heir certificate',
      'Yellow will guide you through the entire claims process'
    ]
  };
};

export const getClaimsGuidance = (assetType) => {
  const guidance = {
    bank_account: {
      title: 'Bank Account Claims',
      documents: [
        'Death Certificate',
        'Legal Heir Certificate / Succession Certificate',
        'Bank account passbook/statement',
        'KYC documents of legal heir',
        'Claim form (provided by bank)'
      ],
      steps: [
        'Visit the bank branch where account is held',
        'Inform about account holder\'s death',
        'Submit death certificate and legal heir documents',
        'Fill claim form for account balance transfer',
        'Bank will verify documents (typically 7-15 days)',
        'Amount will be transferred to legal heir account'
      ],
      timeline: '2-4 weeks',
      tips: [
        'Notify bank immediately to freeze account',
        'Get multiple copies of death certificate',
        'Check if nominee was registered on account'
      ]
    },
    mutual_fund: {
      title: 'Mutual Fund Claims',
      documents: [
        'Death Certificate',
        'Legal Heir Certificate',
        'Original folio documents',
        'KYC documents of legal heir',
        'Transmission request form'
      ],
      steps: [
        'Contact the AMC (Asset Management Company) or RTA',
        'Submit death certificate and transmission request',
        'Provide legal heir documents',
        'AMC will verify and process transmission',
        'Units will be transferred to legal heir\'s folio',
        'You can then redeem or continue holding'
      ],
      timeline: '3-6 weeks',
      tips: [
        'Check if nominee was registered',
        'Contact both AMC and RTA for faster processing',
        'Keep original purchase documents if available'
      ]
    },
    insurance: {
      title: 'Insurance Claims',
      documents: [
        'Death Certificate (original)',
        'Policy document',
        'Claim form (from insurance company)',
        'Claimant\'s ID and bank details',
        'Medical records (if applicable)',
        'Police FIR (for accidental death)'
      ],
      steps: [
        'Inform insurance company immediately',
        'Submit death intimation letter',
        'Fill and submit claim form',
        'Provide all required documents',
        'Insurance company will investigate',
        'Claim amount will be disbursed to nominee/legal heir'
      ],
      timeline: '1-3 months',
      tips: [
        'Notify within time limit specified in policy',
        'For accidental death, file police complaint',
        'Maintain all original policy documents',
        'Follow up regularly with insurance company'
      ]
    },
    fd: {
      title: 'Fixed Deposit Claims',
      documents: [
        'Death Certificate',
        'FD receipt (original)',
        'Legal Heir Certificate',
        'KYC documents of legal heir',
        'Claim form'
      ],
      steps: [
        'Visit bank branch with FD receipt',
        'Submit death certificate and legal documents',
        'Fill claim/premature withdrawal form',
        'Bank will verify documents',
        'FD amount with interest will be paid to legal heir'
      ],
      timeline: '2-3 weeks',
      tips: [
        'Check for nominee registration',
        'Interest will be paid till date of claim',
        'No penalty for premature withdrawal in case of death'
      ]
    },
    nps: {
      title: 'NPS (National Pension System) Claims',
      documents: [
        'Death Certificate',
        'Subscriber registration form',
        'Exit/Withdrawal form',
        'Cancelled cheque of nominee/legal heir',
        'KYC documents of nominee/legal heir'
      ],
      steps: [
        'Inform NPS Trustee and PFM about death',
        'Submit death certificate and exit form',
        'Provide nominee/legal heir documents',
        'NPS will process withdrawal',
        'Corpus will be paid to nominee/legal heir',
        '40% annuitization not mandatory for nominee'
      ],
      timeline: '4-8 weeks',
      tips: [
        'Check if nominee was registered',
        'Nominee gets 100% corpus (annuitization not required)',
        'Contact Point of Presence (PoP) for guidance'
      ]
    },
    securities: {
      title: 'Demat/Securities Claims',
      documents: [
        'Death Certificate',
        'Transmission request form',
        'Legal Heir Certificate',
        'Demat account statement',
        'KYC documents of legal heir'
      ],
      steps: [
        'Contact DP (Depository Participant)',
        'Submit transmission request with death certificate',
        'Provide legal heir documents',
        'Open demat account in legal heir\'s name (if needed)',
        'Securities will be transferred to legal heir',
        'You can then hold or sell securities'
      ],
      timeline: '3-6 weeks',
      tips: [
        'Check for nominee registration',
        'Get fair market value on date of death for tax purposes',
        'Keep record of all holdings and transactions'
      ]
    }
  };

  return guidance[assetType] || {
    title: 'General Asset Claims',
    documents: ['Death Certificate', 'Legal Heir Certificate'],
    steps: ['Contact asset provider', 'Submit required documents'],
    timeline: 'Varies',
    tips: ['Consult with Yellow for professional assistance']
  };
};
