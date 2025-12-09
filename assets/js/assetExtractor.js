// Asset Extraction from Documents using OCR
const AssetExtractor = {
    // Extract asset information from OCR text
    extractAssetInfo(ocrText, fileName) {
        const text = ocrText.toLowerCase();
        const originalText = ocrText;
        
        // Determine asset type
        const assetType = this.identifyAssetType(text, originalText);
        
        // Extract value
        const value = this.extractValue(text, originalText);
        
        // Extract location (for properties)
        const location = this.extractLocation(text, originalText);
        
        // Extract asset name/description
        const name = this.extractAssetName(text, originalText, assetType, fileName);
        
        return {
            type: assetType,
            name: name,
            location: location,
            value: value,
            source: 'manual_upload',
            uploadDate: new Date()
        };
    },

    identifyAssetType(text, originalText) {
        // Property/Real Estate keywords
        const houseKeywords = [
            'house', 'home', 'residential', 'apartment', 'flat', 'villa', 'bungalow',
            'मकान', 'घर', 'अपार्टमेंट', 'फ्लैट', 'विला',
            'வீடு', 'வீட்டு', 'அபார்ட்மெண்ட்', 'பிளாட்',
            'ఇల్లు', 'ఇంటి', 'అపార్ట్మెంట్', 'ఫ్లాట్'
        ];
        
        const landKeywords = [
            'land', 'plot', 'site', 'agricultural land', 'commercial plot',
            'जमीन', 'प्लॉट', 'भूमि', 'कृषि भूमि',
            'நிலம்', 'பிளாட்', 'விளைநிலம்',
            'భూమి', 'ప్లాట్', 'వ్యవసాయ భూమి'
        ];
        
        // Vehicle keywords
        const carKeywords = [
            'car', 'automobile', 'vehicle', 'sedan', 'suv', 'hatchback',
            'कार', 'गाड़ी', 'वाहन', 'सेडान',
            'கார்', 'வாகனம்', 'செடான்',
            'కారు', 'వాహనం', 'సెడాన్'
        ];
        
        const bikeKeywords = [
            'bike', 'motorcycle', 'scooter', 'two wheeler',
            'बाइक', 'मोटरसाइकिल', 'स्कूटर',
            'பைக்', 'மோட்டார் சைக்கிள்', 'ஸ்கூட்டர்',
            'బైక్', 'మోటార్ సైకిల్', 'స్కూటర్'
        ];
        
        // Check for property types
        if (landKeywords.some(kw => text.includes(kw) || originalText.includes(kw))) {
            return 'Land';
        } else if (houseKeywords.some(kw => text.includes(kw) || originalText.includes(kw))) {
            if (text.includes('apartment') || text.includes('flat') || text.includes('अपार्टमेंट') || text.includes('அபார்ட்மெண்ட்') || text.includes('అపార్ట్మెంట్')) {
                return 'Property';
            } else if (text.includes('commercial') || text.includes('व्यावसायिक') || text.includes('வணிக') || text.includes('వాణిజ్య')) {
                return 'Property';
            }
            return 'Property';
        } else if (bikeKeywords.some(kw => text.includes(kw) || originalText.includes(kw))) {
            return 'Vehicle';
        } else if (carKeywords.some(kw => text.includes(kw) || originalText.includes(kw))) {
            return 'Vehicle';
        } else if (text.includes('property') || text.includes('संपत्ति') || text.includes('சொத்து') || text.includes('ఆస్తి')) {
            return 'Property';
        } else if (text.includes('registration') || text.includes('पंजीकरण') || text.includes('பதிவு') || text.includes('నమోదు')) {
            // Default to Property if it's a registration document
            return 'Property';
        }
        
        return 'Other';
    },

    extractValue(text, originalText) {
        // Patterns to match currency values
        const patterns = [
            // ₹1,23,456 or ₹12,34,567 format
            /₹\s*(\d{1,2}(?:,\d{2})*(?:,\d{3})?)/g,
            // Rs. 1,23,456
            /rs\.?\s*(\d{1,2}(?:,\d{2})*(?:,\d{3})?)/gi,
            // INR 1,23,456
            /inr\s*(\d{1,2}(?:,\d{2})*(?:,\d{3})?)/gi,
            // Just numbers with lakhs/crores
            /(\d+(?:\.\d+)?)\s*(lakh|lac|लाख|லட்சம்|లక్ష)/gi,
            /(\d+(?:\.\d+)?)\s*(crore|करोड़|கோடி|కోటి)/gi,
            // Value: ₹X or Amount: ₹X
            /(?:value|amount|price|cost|valuation|worth)[\s:]*₹?\s*(\d{1,2}(?:,\d{2})*(?:,\d{3})?)/gi,
        ];
        
        let maxValue = 0;
        
        // Try all patterns
        patterns.forEach(pattern => {
            const matches = originalText.matchAll(pattern);
            for (const match of matches) {
                let value = 0;
                
                if (match[2] && (match[2].toLowerCase().includes('lakh') || match[2].toLowerCase().includes('lac') || match[2].toLowerCase().includes('लाख') || match[2].toLowerCase().includes('லட்சம்') || match[2].toLowerCase().includes('లక్ష'))) {
                    value = parseFloat(match[1]) * 100000;
                } else if (match[2] && (match[2].toLowerCase().includes('crore') || match[2].toLowerCase().includes('करोड़') || match[2].toLowerCase().includes('கோடி') || match[2].toLowerCase().includes('కోటి'))) {
                    value = parseFloat(match[1]) * 10000000;
                } else {
                    // Remove commas and parse
                    const numStr = match[1].replace(/,/g, '');
                    value = parseFloat(numStr);
                }
                
                // Validate value is reasonable (between ₹10,000 and ₹100 crores)
                if (value >= 10000 && value <= 10000000000 && value > maxValue) {
                    maxValue = value;
                }
            }
        });
        
        // If no value found, try to find any large number near value keywords
        if (maxValue === 0) {
            const valueContextPattern = /(?:value|amount|price|cost|valuation|worth|total|consideration|sale|purchase|paid)[\s:]*[\d\s,]+/gi;
            const contextMatches = originalText.matchAll(valueContextPattern);
            for (const match of contextMatches) {
                const numbers = match[0].match(/\d{1,2}(?:,\d{2})*(?:,\d{3})?/g);
                if (numbers) {
                    numbers.forEach(numStr => {
                        const num = parseFloat(numStr.replace(/,/g, ''));
                        if (num >= 10000 && num <= 10000000000 && num > maxValue) {
                            maxValue = num;
                        }
                    });
                }
            }
        }

        // Additional pattern: Look for numbers in lakhs/crores format without explicit keywords
        if (maxValue === 0) {
            const lakhCrorePattern = /(\d+(?:\.\d+)?)\s*(?:lakh|lac|लाख|லட்சம்|లక్ష|crore|करोड़|கோடி|కోటి)/gi;
            const matches = originalText.matchAll(lakhCrorePattern);
            for (const match of matches) {
                let value = parseFloat(match[1]);
                if (match[0].toLowerCase().includes('crore') || match[0].includes('करोड़') || match[0].includes('கோடி') || match[0].includes('కోటి')) {
                    value *= 10000000;
                } else {
                    value *= 100000;
                }
                if (value >= 10000 && value <= 10000000000 && value > maxValue) {
                    maxValue = value;
                }
            }
        }
        
        return maxValue;
    },

    extractLocation(text, originalText) {
        // Common Indian cities
        const cities = [
            'mumbai', 'delhi', 'bangalore', 'hyderabad', 'chennai', 'kolkata', 'pune',
            'ahmedabad', 'jaipur', 'surat', 'lucknow', 'kanpur', 'nagpur', 'indore',
            'thane', 'bhopal', 'visakhapatnam', 'patna', 'vadodara', 'gurgaon',
            'coimbatore', 'agra', 'madurai', 'nashik', 'faridabad', 'meerut',
            'rajkot', 'varanasi', 'srinagar', 'amritsar', 'ludhiana', 'chandigarh',
            'मुंबई', 'दिल्ली', 'बैंगलोर', 'हैदराबाद', 'चेन्नई', 'कोलकाता', 'पुणे',
            'மும்பை', 'டெல்லி', 'பெங்களூரு', 'ஹைதராபாத்', 'சென்னை', 'கொல்கத்தா',
            'ముంబై', 'ఢిల్లీ', 'బెంగళూరు', 'హైదరాబాద్', 'చెన్నై', 'కోల్కతా'
        ];
        
        // Look for city names
        for (const city of cities) {
            if (text.includes(city) || originalText.toLowerCase().includes(city)) {
                return city.charAt(0).toUpperCase() + city.slice(1);
            }
        }
        
        // Look for state names or other location indicators
        const locationPatterns = [
            /(?:located|situated|address|at)[\s:]+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)/g,
            /([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)[\s,]+(?:state|district|taluk)/gi
        ];
        
        for (const pattern of locationPatterns) {
            const matches = originalText.matchAll(pattern);
            for (const match of matches) {
                if (match[1] && match[1].length > 2 && match[1].length < 30) {
                    return match[1];
                }
            }
        }
        
        return null;
    },

    extractAssetName(text, originalText, assetType, fileName) {
        // Try to extract property/asset name from document
        const namePatterns = [
            /(?:property|asset|house|apartment|flat|plot|land|vehicle|car|bike)[\s:]+([A-Z][a-zA-Z0-9\s-]+)/gi,
            /([A-Z][a-zA-Z0-9\s-]+)\s+(?:apartment|flat|house|villa|plot|land|car|bike|vehicle)/gi,
            /(?:name|title|description)[\s:]+([A-Z][a-zA-Z0-9\s-]+)/gi
        ];
        
        for (const pattern of namePatterns) {
            const matches = originalText.matchAll(pattern);
            for (const match of matches) {
                if (match[1] && match[1].length > 3 && match[1].length < 50) {
                    return match[1].trim();
                }
            }
        }
        
        // Fallback: Generate name based on type
        if (assetType === 'Property') {
            return 'Residential Property';
        } else if (assetType === 'Land') {
            return 'Land/Plot';
        } else if (assetType === 'Vehicle') {
            return 'Vehicle';
        } else {
            // Use filename without extension
            return fileName.replace(/\.[^/.]+$/, '') || 'Asset';
        }
    },

    async extractAssetFromFile(file, progressCallback) {
        try {
            // Convert file to image
            let imageDataUrl = null;
            if (progressCallback) {
                progressCallback('Converting document to image...', 0);
            }
            
            if (file.type === 'application/pdf') {
                imageDataUrl = await this.convertPdfToImage(file);
            } else {
                imageDataUrl = await this.fileToDataUrl(file);
            }
            
            if (progressCallback) {
                progressCallback('Performing OCR...', 0.1);
            }
            
            // Perform OCR
            const ocrText = await this.performOCR(imageDataUrl, progressCallback);
            
            if (progressCallback) {
                progressCallback('Extracting asset details...', 0.9);
            }
            
            // Extract asset information
            const assetInfo = this.extractAssetInfo(ocrText, file.name);
            assetInfo.ocrText = ocrText; // Store OCR text for debugging
            
            // Log for debugging
            console.log('=== OCR EXTRACTION RESULTS ===');
            console.log('OCR Text Length:', ocrText.length);
            console.log('OCR Text Sample:', ocrText.substring(0, 200));
            console.log('Extracted Asset Info:', assetInfo);
            console.log('Extracted Value:', assetInfo.value);
            console.log('================================');
            
            if (progressCallback) {
                progressCallback('Complete!', 1);
            }
            
            return assetInfo;
        } catch (error) {
            console.error('Error extracting asset from file:', error);
            throw error;
        }
    },

    async fileToDataUrl(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = (e) => resolve(e.target.result);
            reader.onerror = reject;
            reader.readAsDataURL(file);
        });
    },

    async convertPdfToImage(file) {
        const arrayBuffer = await file.arrayBuffer();
        const pdf = await pdfjsLib.getDocument({ data: arrayBuffer }).promise;
        const page = await pdf.getPage(1);
        
        const viewport = page.getViewport({ scale: 2.0 });
        const canvas = document.createElement('canvas');
        const context = canvas.getContext('2d');
        canvas.height = viewport.height;
        canvas.width = viewport.width;

        await page.render({
            canvasContext: context,
            viewport: viewport
        }).promise;

        return canvas.toDataURL('image/png');
    },

    async performOCR(imageDataUrl, progressCallback) {
        const languages = 'eng+hin+tam+tel+kan+mal+ben+guj+pan+ori+asm+mar';
        
        try {
            const { data: { text } } = await Tesseract.recognize(
                imageDataUrl,
                languages,
                { 
                    logger: (m) => {
                        if (progressCallback && m.status) {
                            progressCallback(m.status, m.progress);
                        }
                    }
                }
            );
            return text;
        } catch (error) {
            console.warn('Multi-language OCR failed, trying English only:', error);
            if (progressCallback) {
                progressCallback('Falling back to English OCR...', 0);
            }
            const { data: { text } } = await Tesseract.recognize(
                imageDataUrl,
                'eng',
                { 
                    logger: (m) => {
                        if (progressCallback && m.status) {
                            progressCallback(m.status, m.progress);
                        }
                    }
                }
            );
            return text;
        }
    }
};

