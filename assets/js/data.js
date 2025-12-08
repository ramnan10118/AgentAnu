// Mock Asset Data
// TODO: Replace with Account Aggregator API call
const mockAssetData = {
    bankSavings: {
        total: 1247350,
        accounts: 3,
        details: [
            { bank: 'HDFC Bank', accountNumber: '****1234', balance: 452387, type: 'Savings' },
            { bank: 'ICICI Bank', accountNumber: '****5678', balance: 598621, type: 'Savings' },
            { bank: 'State Bank of India', accountNumber: '****9012', balance: 196342, type: 'Current' }
        ]
    },
    loans: {
        total: 3528476,
        count: 2,
        details: [
            { 
                lender: 'HDFC Bank', 
                loanType: 'Home Loan', 
                purpose: 'House Purchase',
                outstanding: 2834921, 
                originalAmount: 4250000,
                paidAmount: 1415079,
                emi: 25147, 
                tenure: 180,
                remainingMonths: 132,
                startDate: '2019-01-15'
            },
            { 
                lender: 'Bajaj Finserv', 
                loanType: 'Personal Loan', 
                purpose: 'Personal',
                outstanding: 693555, 
                originalAmount: 1025000,
                paidAmount: 331445,
                emi: 15234, 
                tenure: 60,
                remainingMonths: 20,
                startDate: '2022-06-01'
            }
        ]
    },
    assets: {
        total: 8475234,
        count: 3,
        details: [
            { name: 'Residential Apartment', location: 'Bangalore', value: 6487234, type: 'Property' },
            { name: 'Commercial Plot', location: 'Hyderabad', value: 1523400, type: 'Land' },
            { name: 'Maruti Swift', value: 464600, type: 'Vehicle' }
        ]
    },
    mutualFunds: {
        total: 847293,
        count: 6,
        details: [
            { name: 'HDFC Equity Fund', amount: 198234, returns: '+12.47%', type: 'Equity' },
            { name: 'SBI Bluechip Fund', amount: 182156, returns: '+15.23%', type: 'Equity' },
            { name: 'ICICI Prudential Balanced', amount: 151892, returns: '+10.81%', type: 'Hybrid' },
            { name: 'Axis Long Term Equity', amount: 123478, returns: '+18.34%', type: 'ELSS' },
            { name: 'UTI Nifty 50 Index', amount: 98765, returns: '+14.12%', type: 'Index' },
            { name: 'Franklin India Bluechip', amount: 92768, returns: '+11.89%', type: 'Equity' }
        ]
    },
    stocks: {
        total: 1187432,
        count: 8,
        details: [
            { symbol: 'RELIANCE', name: 'Reliance Industries', quantity: 50, value: 124387, returns: '+8.47%' },
            { symbol: 'TCS', name: 'Tata Consultancy Services', quantity: 30, value: 112456, returns: '+12.31%' },
            { symbol: 'INFY', name: 'Infosys Limited', quantity: 100, value: 152389, returns: '+15.21%' },
            { symbol: 'HDFCBANK', name: 'HDFC Bank', quantity: 80, value: 141234, returns: '+9.78%' },
            { symbol: 'ICICIBANK', name: 'ICICI Bank', quantity: 120, value: 128967, returns: '+11.43%' },
            { symbol: 'BHARTIARTL', name: 'Bharti Airtel', quantity: 200, value: 182345, returns: '+22.14%' },
            { symbol: 'ITC', name: 'ITC Limited', quantity: 500, value: 198234, returns: '+6.72%' },
            { symbol: 'SBIN', name: 'State Bank of India', quantity: 300, value: 189422, returns: '+13.89%' }
        ]
    },
    digitalGold: {
        total: 74238,
        count: 1,
        details: [
            { platform: 'Paytm Gold', units: 15.47, value: 74238, currentPrice: 4798 }
        ]
    }
};

