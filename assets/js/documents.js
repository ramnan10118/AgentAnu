// Document Management Module
// Uses global scope for compatibility

const DocumentManager = {
    documents: [],
    MAX_DOCUMENTS: 5,
    elements: {},

    init() {
        this.elements.uploadArea = document.getElementById('uploadArea');
        this.elements.fileInput = document.getElementById('fileInput');
        this.elements.fileInputSmall = document.getElementById('fileInputSmall');
        this.elements.errorMessage = document.getElementById('errorMessage');
        this.elements.documentsList = document.getElementById('documentsList');
        this.elements.uploadCard = document.getElementById('uploadCard');
        this.elements.uploadMoreButton = document.getElementById('uploadMoreButton');
        this.elements.uploadMoreBtn = document.getElementById('uploadMoreBtn');

        this.setupEventListeners();
        this.configurePDFJS();
    },

    configurePDFJS() {
        if (typeof pdfjsLib !== 'undefined') {
            pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js';
        }
    },

    setupEventListeners() {
        this.elements.uploadArea?.addEventListener('click', () => {
            if (this.documents.length < this.MAX_DOCUMENTS) {
                this.elements.fileInput?.click();
            }
        });

        this.elements.uploadMoreBtn?.addEventListener('click', () => {
            if (this.documents.length < this.MAX_DOCUMENTS) {
                this.elements.fileInputSmall?.click();
            }
        });

        this.elements.fileInput?.addEventListener('change', (e) => {
            if (e.target.files.length > 0) {
                this.handleFiles(Array.from(e.target.files));
            }
        });

        this.elements.fileInputSmall?.addEventListener('change', (e) => {
            if (e.target.files.length > 0) {
                this.handleFiles(Array.from(e.target.files));
            }
        });

        // Drag and drop
        this.elements.uploadArea?.addEventListener('dragover', (e) => {
            e.preventDefault();
            if (this.documents.length < this.MAX_DOCUMENTS) {
                this.elements.uploadArea.classList.add('bg-accent', 'border-primary');
            }
        });

        this.elements.uploadArea?.addEventListener('dragleave', () => {
            this.elements.uploadArea?.classList.remove('bg-accent', 'border-primary');
        });

        this.elements.uploadArea?.addEventListener('drop', (e) => {
            e.preventDefault();
            this.elements.uploadArea?.classList.remove('bg-accent', 'border-primary');
            if (this.documents.length < this.MAX_DOCUMENTS) {
                this.handleFiles(Array.from(e.dataTransfer.files));
            }
        });
    },

    handleFiles(files) {
        const remainingSlots = this.MAX_DOCUMENTS - this.documents.length;
        const filesToAdd = files.slice(0, remainingSlots);

        if (files.length > remainingSlots) {
            this.showError(`You can only upload ${remainingSlots} more document(s). Maximum ${this.MAX_DOCUMENTS} documents allowed.`);
        }

        filesToAdd.forEach(file => {
            if (this.documents.length >= this.MAX_DOCUMENTS) return;

            const validTypes = ['image/png', 'image/jpeg', 'image/jpg', 'application/pdf'];
            if (!validTypes.includes(file.type)) {
                this.showError(`${file.name} is not a valid file type. Please upload PNG, JPEG, or PDF files.`);
                return;
            }

            this.addDocument(file);
        });

        // Reset file inputs
        if (this.elements.fileInput) this.elements.fileInput.value = '';
        if (this.elements.fileInputSmall) this.elements.fileInputSmall.value = '';
    },

    showError(message) {
        if (!this.elements.errorMessage) return;
        this.elements.errorMessage.textContent = message;
        this.elements.errorMessage.classList.remove('hidden');
        setTimeout(() => {
            this.elements.errorMessage.classList.add('hidden');
        }, 5000);
    },

    async addDocument(file) {
        const documentId = Date.now().toString();
        const document = {
            id: documentId,
            file: file,
            name: file.name,
            type: file.type,
            uploadDate: new Date(),
            isProcessing: true
        };

        this.documents.push(document);
        this.renderDocuments();

        // Process document (OCR for type detection)
        try {
            const documentType = await this.identifyDocumentType(file);
            document.name = documentType;
            document.isProcessing = false;
            this.renderDocuments();
        } catch (error) {
            console.error('Error processing document:', error);
            document.name = file.name;
            document.isProcessing = false;
            this.renderDocuments();
        }
    },

    async identifyDocumentType(file) {
        try {
            let imageDataUrl = null;

            if (file.type === 'application/pdf') {
                imageDataUrl = await this.convertPdfToImage(file);
            } else {
                imageDataUrl = await this.fileToDataUrl(file);
            }

            const ocrText = await this.performOCR(imageDataUrl);
            return this.identifyDocumentTypeFromText(ocrText, file.name);
        } catch (error) {
            console.error('OCR error:', error);
            return file.name;
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

    async performOCR(imageDataUrl) {
        const languages = 'eng+hin+tam+tel+kan+mal+ben+guj+pan+ori+asm+mar';
        
        try {
            const { data: { text } } = await Tesseract.recognize(
                imageDataUrl,
                languages,
                { logger: () => {} }
            );
            return text;
        } catch (error) {
            console.warn('Multi-language OCR failed, trying English only:', error);
            const { data: { text } } = await Tesseract.recognize(
                imageDataUrl,
                'eng',
                { logger: () => {} }
            );
            return text;
        }
    },

    identifyDocumentTypeFromText(ocrText, fileName) {
        const text = ocrText.toLowerCase();
        const originalText = ocrText;

        const saleDeedKeywords = [
            'sale deed', 'sale agreement', 'conveyance deed',
            'बिक्री पत्र', 'बिक्री समझौता', 'विक्रय पत्र',
            'விற்பனை பத்திரம்', 'விற்பனை ஒப்பந்தம்',
            'విక్రయ పత్రం', 'విక్రయ ఒప్పందం'
        ];

        const propertyTaxKeywords = [
            'property tax', 'house tax', 'building tax',
            'संपत्ति कर', 'मकान कर', 'भवन कर',
            'சொத்து வரி', 'வீடு வரி', 'கட்டிட வரி',
            'ఆస్తి పన్ను', 'ఇల్లు పన్ను', 'భవనం పన్ను'
        ];

        const propertyRegistrationKeywords = [
            'property registration', 'house registration', 'apartment registration',
            'land registration', 'plot registration',
            'संपत्ति पंजीकरण', 'मकान पंजीकरण', 'भूमि पंजीकरण',
            'சொத்து பதிவு', 'வீடு பதிவு', 'நிலம் பதிவு',
            'ఆస్తి నమోదు', 'ఇల్లు నమోదు', 'భూమి నమోదు'
        ];

        const identityKeywords = [
            'aadhaar', 'aadhar', 'pan card', 'passport', 'driving license', 'voter id',
            'आधार', 'पैन कार्ड', 'पासपोर्ट', 'ड्राइविंग लाइसेंस',
            'ஆதார்', 'பான் கார்டு', 'பாஸ்போர்ட்', 'ஓட்டர் ஐடி',
            'ఆధార్', 'పాన్ కార్డ్', 'పాస్పోర్ట్', 'డ్రైవింగ్ లైసెన్స్'
        ];

        const insuranceKeywords = [
            'insurance', 'policy', 'coverage',
            'बीमा', 'पॉलिसी', 'कवरेज',
            'காப்பீடு', 'பாலிசி', 'கவரேஜ்',
            'బీమా', 'పాలసీ', 'కవరేజ్'
        ];

        if (identityKeywords.some(kw => text.includes(kw) || originalText.includes(kw))) {
            if (text.includes('aadhaar') || text.includes('aadhar') || text.includes('आधार') || text.includes('ஆதார்') || text.includes('ఆధార్')) {
                return 'Aadhaar Card';
            } else if (text.includes('pan') || text.includes('पैन') || text.includes('பான்') || text.includes('పాన్')) {
                return 'PAN Card';
            } else if (text.includes('passport') || text.includes('पासपोर्ट') || text.includes('பாஸ்போர்ட்') || text.includes('పాస్పోర్ట్')) {
                return 'Passport';
            } else {
                return 'Identity Document';
            }
        } else if (saleDeedKeywords.some(kw => text.includes(kw) || originalText.includes(kw))) {
            return 'Sale Deed';
        } else if (propertyTaxKeywords.some(kw => text.includes(kw) || originalText.includes(kw))) {
            return 'Property Tax Document';
        } else if (propertyRegistrationKeywords.some(kw => text.includes(kw) || originalText.includes(kw))) {
            if (text.includes('land') || text.includes('plot') || text.includes('जमीन') || text.includes('நிலம்') || text.includes('భూమి')) {
                return 'Land Registration';
            } else if (text.includes('apartment') || text.includes('flat') || text.includes('अपार्टमेंट') || text.includes('அபார்ட்மெண்ட்') || text.includes('అపార్ట్మెంట్')) {
                return 'Apartment Registration';
            } else {
                return 'Property Registration';
            }
        } else if (insuranceKeywords.some(kw => text.includes(kw) || originalText.includes(kw))) {
            return 'Insurance Document';
        } else if (text.includes('registration') || text.includes('पंजीकरण') || text.includes('பதிவு') || text.includes('నమోదు')) {
            return 'Registration Document';
        } else if (text.includes('property') || text.includes('house') || text.includes('संपत्ति') || text.includes('மனை') || text.includes('ఆస్తి')) {
            return 'Property Document';
        } else {
            const nameWithoutExt = fileName.replace(/\.[^/.]+$/, '');
            return nameWithoutExt || 'Document';
        }
    },

    renderDocuments() {
        if (!this.elements.documentsList) return;
        
        this.elements.documentsList.innerHTML = '';

        if (this.documents.length === 0) {
            if (this.elements.uploadCard) this.elements.uploadCard.classList.remove('hidden');
            if (this.elements.uploadMoreButton) this.elements.uploadMoreButton.classList.add('hidden');
            return;
        }

        this.documents.forEach((doc) => {
            const card = this.createDocumentCard(doc);
            this.elements.documentsList.appendChild(card);
        });

        if (this.documents.length < this.MAX_DOCUMENTS) {
            if (this.elements.uploadCard) this.elements.uploadCard.classList.add('hidden');
            if (this.elements.uploadMoreButton) this.elements.uploadMoreButton.classList.remove('hidden');
        } else {
            if (this.elements.uploadCard) this.elements.uploadCard.classList.add('hidden');
            if (this.elements.uploadMoreButton) this.elements.uploadMoreButton.classList.add('hidden');
        }
    },

    createDocumentCard(doc) {
        const card = document.createElement('div');
        card.className = 'bg-card text-card-foreground rounded-lg border shadow-sm p-4';
        card.dataset.documentId = doc.id;

        let formatIcon = `
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"></path>
            </svg>
        `;
        
        if (doc.type === 'image/png') {
            formatIcon = `
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                </svg>
            `;
        } else if (doc.type === 'image/jpeg' || doc.type === 'image/jpg') {
            formatIcon = `
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                </svg>
            `;
        }

        const uploadDate = doc.uploadDate ? Utils.formatDate(doc.uploadDate) : 'Just now';

        card.innerHTML = `
            <div class="flex items-center justify-between">
                <div class="flex items-center space-x-3 flex-1 min-w-0">
                    <div class="flex-shrink-0 text-muted-foreground">
                        ${formatIcon}
                    </div>
                    <div class="flex-1 min-w-0">
                        <input 
                            type="text" 
                            value="${Utils.escapeHtml(doc.name)}" 
                            class="text-sm font-medium bg-transparent border-none outline-none focus:ring-2 focus:ring-ring rounded px-2 -ml-2 w-full"
                            data-document-id="${doc.id}"
                            onchange="DocumentManager.updateDocumentName('${doc.id}', this.value)"
                            ${doc.isProcessing ? 'disabled' : ''}
                        >
                        <p class="text-xs text-muted-foreground mt-0.5">${uploadDate}</p>
                    </div>
                </div>
                <button 
                    onclick="DocumentManager.deleteDocument('${doc.id}')"
                    class="ml-4 flex-shrink-0 text-muted-foreground hover:text-destructive transition-colors p-1"
                    title="Delete document"
                    ${doc.isProcessing ? 'disabled' : ''}
                >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                    </svg>
                </button>
            </div>
            ${doc.isProcessing ? `
                <div class="mt-3 flex items-center space-x-2 text-xs text-muted-foreground">
                    <div class="inline-block h-3 w-3 animate-spin rounded-full border-2 border-solid border-current border-r-transparent"></div>
                    <span>Processing document...</span>
                </div>
            ` : ''}
        `;

        return card;
    },

    updateDocumentName(documentId, newName) {
        const doc = this.documents.find(d => d.id === documentId);
        if (doc) {
            doc.name = newName || 'Document';
        }
    },

    deleteDocument(documentId) {
        this.documents = this.documents.filter(d => d.id !== documentId);
        this.renderDocuments();
    }
};
