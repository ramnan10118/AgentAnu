// Asset Upload Handler
const AssetUpload = {
    currentFile: null,
    extractedAsset: null,
    isInitialized: false,
    isAdding: false, // Prevent duplicate additions

    init() {
        // Prevent multiple initializations
        if (this.isInitialized) return;
        this.isInitialized = true;

        const uploadArea = document.getElementById('addAssetUploadArea');
        const fileInput = document.getElementById('assetFileInput');
        const confirmBtn = document.getElementById('confirmAddAssetBtn');
        const cancelBtn = document.getElementById('cancelAddAssetBtn');
        const editBtn = document.getElementById('editAssetBtn');

        uploadArea?.addEventListener('click', () => {
            fileInput?.click();
        });

        fileInput?.addEventListener('change', (e) => {
            if (e.target.files.length > 0) {
                this.handleFileUpload(e.target.files[0]);
            }
        });

        // Drag and drop
        uploadArea?.addEventListener('dragover', (e) => {
            e.preventDefault();
            uploadArea.classList.add('bg-accent', 'border-primary');
        });

        uploadArea?.addEventListener('dragleave', () => {
            uploadArea?.classList.remove('bg-accent', 'border-primary');
        });

        uploadArea?.addEventListener('drop', (e) => {
            e.preventDefault();
            uploadArea?.classList.remove('bg-accent', 'border-primary');
            if (e.dataTransfer.files.length > 0) {
                this.handleFileUpload(e.dataTransfer.files[0]);
            }
        });

        // Use once: true to prevent multiple listeners, or check if already added
        if (confirmBtn && !confirmBtn.dataset.listenerAdded) {
            confirmBtn.addEventListener('click', (e) => {
                e.preventDefault();
                e.stopPropagation();
                this.confirmAddAsset();
            });
            confirmBtn.dataset.listenerAdded = 'true';
        }

        if (cancelBtn && !cancelBtn.dataset.listenerAdded) {
            cancelBtn.addEventListener('click', () => {
                this.cancelAddAsset();
            });
            cancelBtn.dataset.listenerAdded = 'true';
        }

        if (editBtn && !editBtn.dataset.listenerAdded) {
            editBtn.addEventListener('click', () => {
                this.showEditForm();
            });
            editBtn.dataset.listenerAdded = 'true';
        }
    },

    async handleFileUpload(file) {
        const validTypes = ['image/png', 'image/jpeg', 'image/jpg', 'application/pdf'];
        if (!validTypes.includes(file.type)) {
            this.showError('Please upload PNG, JPEG, or PDF files only.');
            return;
        }

        this.currentFile = file;
        this.showProcessing();

        try {
            // Progress callback for OCR
            const updateProgress = (status, progress) => {
                this.updateProcessingStatus(status, progress);
            };

            console.log('Starting OCR extraction for file:', file.name);
            
            // Extract asset information using OCR
            const assetInfo = await AssetExtractor.extractAssetFromFile(file, updateProgress);
            
            console.log('OCR Extraction completed. Asset Info:', assetInfo);
            console.log('Extracted Value:', assetInfo.value);
            
            // Ensure value is a number (default to 0 if not found)
            if (!assetInfo.value || assetInfo.value === 0) {
                assetInfo.value = 0;
                console.warn('No value extracted from document');
            }
            
            this.extractedAsset = assetInfo;
            this.showExtractedAsset(assetInfo);
        } catch (error) {
            console.error('Error extracting asset:', error);
            this.showError('Failed to extract asset details. Please try again or add the asset manually.');
            this.hideProcessing();
        }
    },

    showProcessing() {
        document.getElementById('assetProcessingStatus')?.classList.remove('hidden');
        document.getElementById('extractedAssetPreview')?.classList.add('hidden');
        document.getElementById('assetErrorMessage')?.classList.add('hidden');
        this.updateProcessingStatus('Starting OCR...', 0);
    },

    updateProcessingStatus(status, progress) {
        const statusDiv = document.getElementById('assetProcessingStatus');
        const statusText = document.getElementById('processingStatusText');
        const subtext = document.getElementById('processingSubtext');
        const progressBar = document.getElementById('processingProgressBar');
        const progressPercent = document.getElementById('processingPercent');
        
        if (!statusDiv) return;
        
        const progressPercentValue = Math.round((progress || 0) * 100);
        
        // Update status text
        if (statusText) {
            statusText.textContent = status || 'Processing...';
        }
        
        // Update subtext based on status
        if (subtext) {
            if (status.includes('Converting')) {
                subtext.textContent = 'Preparing document for analysis';
            } else if (status.includes('OCR') || status.includes('recognizing')) {
                subtext.textContent = 'Reading text from document';
            } else if (status.includes('Extracting')) {
                subtext.textContent = 'Identifying asset details and value';
            } else if (status.includes('Complete')) {
                subtext.textContent = 'Extraction completed successfully';
            } else {
                subtext.textContent = 'Analyzing document content';
            }
        }
        
        // Update progress bar
        if (progressBar) {
            progressBar.style.width = `${progressPercentValue}%`;
        }
        
        // Update percentage
        if (progressPercent) {
            progressPercent.textContent = `${progressPercentValue}%`;
        }
    },

    hideProcessing() {
        document.getElementById('assetProcessingStatus')?.classList.add('hidden');
    },

    showExtractedAsset(assetInfo) {
        console.log('=== DISPLAYING EXTRACTED ASSET ===');
        console.log('Asset Info:', assetInfo);
        console.log('Extracted Value:', assetInfo.value);
        
        this.hideProcessing();
        const preview = document.getElementById('extractedAssetPreview');
        const valueDisplay = document.getElementById('extractedValueDisplay');
        const valueAmount = document.getElementById('extractedValueAmount');
        const valueStatus = document.getElementById('extractedValueStatus');
        const infoContainer = document.getElementById('extractedAssetInfo');
        
        if (!preview) {
            console.error('Preview element not found!');
            alert('Error: Preview section not found. Check console for details.');
            return;
        }

        const typeLabels = {
            'Property': '🏠 Property',
            'Land': '🌾 Land/Plot',
            'Vehicle': '🚗 Vehicle',
            'Other': '📦 Other Asset'
        };

        const typeLabel = typeLabels[assetInfo.type] || '📦 Asset';
        const valueFound = assetInfo.value > 0;
        const valueText = valueFound ? Utils.formatCurrency(assetInfo.value) : 'Not Detected';

        // Update the value display
        if (valueAmount) {
            valueAmount.textContent = valueText;
        }
        
        if (valueStatus) {
            if (valueFound) {
                valueStatus.textContent = 'Successfully extracted from document';
                if (valueDisplay) {
                    valueDisplay.className = 'bg-gradient-to-r from-emerald-50 to-green-50 border-b border-gray-200 px-8 py-6';
                    const icon = valueDisplay.querySelector('svg');
                    if (icon) {
                        icon.className = 'w-8 h-8 text-green-600';
                        icon.parentElement.className = 'w-16 h-16 bg-green-100 rounded-full flex items-center justify-center';
                    }
                }
            } else {
                valueStatus.textContent = 'Value not detected - Click Edit to enter manually';
                if (valueDisplay) {
                    valueDisplay.className = 'bg-gradient-to-r from-orange-50 to-amber-50 border-b border-gray-200 px-8 py-6';
                    const icon = valueDisplay.querySelector('svg');
                    if (icon) {
                        icon.className = 'w-8 h-8 text-orange-600';
                        icon.parentElement.className = 'w-16 h-16 bg-orange-100 rounded-full flex items-center justify-center';
                        // Change icon to warning
                        icon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>';
                    }
                }
            }
        }

        // Update asset details with beautiful cards
        if (infoContainer) {
            infoContainer.innerHTML = `
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <!-- Asset Type Card -->
                    <div class="bg-gray-50 rounded-lg p-4 border border-gray-200">
                        <div class="flex items-center gap-3 mb-2">
                            <div class="w-10 h-10 bg-gray-200 rounded-lg flex items-center justify-center">
                                <svg class="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"></path>
                                </svg>
                            </div>
                            <div class="flex-1">
                                <p class="text-xs font-medium text-gray-500 uppercase tracking-wide mb-1">Asset Type</p>
                                <p class="text-base font-semibold text-gray-900">${typeLabel}</p>
                            </div>
                        </div>
                    </div>

                    <!-- Asset Name Card -->
                    <div class="bg-gray-50 rounded-lg p-4 border border-gray-200">
                        <div class="flex items-center gap-3 mb-2">
                            <div class="w-10 h-10 bg-gray-200 rounded-lg flex items-center justify-center">
                                <svg class="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"></path>
                                </svg>
                            </div>
                            <div class="flex-1">
                                <p class="text-xs font-medium text-gray-500 uppercase tracking-wide mb-1">Asset Name</p>
                                <p class="text-base font-semibold text-gray-900">${assetInfo.name}</p>
                            </div>
                        </div>
                    </div>

                    ${assetInfo.location ? `
                    <!-- Location Card -->
                    <div class="bg-gray-50 rounded-lg p-4 border border-gray-200">
                        <div class="flex items-center gap-3 mb-2">
                            <div class="w-10 h-10 bg-gray-200 rounded-lg flex items-center justify-center">
                                <svg class="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                </svg>
                            </div>
                            <div class="flex-1">
                                <p class="text-xs font-medium text-gray-500 uppercase tracking-wide mb-1">Location</p>
                                <p class="text-base font-semibold text-gray-900">${assetInfo.location}</p>
                            </div>
                        </div>
                    </div>
                    ` : ''}

                    <!-- Value Card -->
                    <div class="bg-gradient-to-br ${valueFound ? 'from-green-50 to-emerald-50' : 'from-orange-50 to-amber-50'} rounded-lg p-4 border-2 ${valueFound ? 'border-green-200' : 'border-orange-200'}">
                        <div class="flex items-center gap-3 mb-2">
                            <div class="w-10 h-10 ${valueFound ? 'bg-green-100' : 'bg-orange-100'} rounded-lg flex items-center justify-center">
                                <svg class="w-5 h-5 ${valueFound ? 'text-green-600' : 'text-orange-600'}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                </svg>
                            </div>
                            <div class="flex-1">
                                <p class="text-xs font-medium ${valueFound ? 'text-green-700' : 'text-orange-700'} uppercase tracking-wide mb-1">Estimated Value</p>
                                <p class="text-lg font-bold ${valueFound ? 'text-green-700' : 'text-orange-700'}">${valueText}</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- OCR Debug Section -->
                <details class="mt-6 pt-6 border-t border-gray-200">
                    <summary class="cursor-pointer text-sm font-medium text-gray-600 hover:text-gray-900 flex items-center gap-2">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                        </svg>
                        View OCR Text (Debug)
                    </summary>
                    <div class="mt-4 p-4 bg-gray-50 rounded-lg border border-gray-200">
                        <pre class="text-xs font-mono text-gray-700 whitespace-pre-wrap max-h-48 overflow-y-auto">${assetInfo.ocrText ? assetInfo.ocrText.substring(0, 1000) + (assetInfo.ocrText.length > 1000 ? '\n\n... (truncated)' : '') : 'No OCR text available'}</pre>
                    </div>
                </details>
            `;
        }

        // Show the preview - THIS IS CRITICAL
        preview.classList.remove('hidden');
        console.log('Preview is now visible');
        
        // Scroll to the preview
        preview.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    },

    showError(message) {
        const errorDiv = document.getElementById('assetErrorMessage');
        if (errorDiv) {
            errorDiv.textContent = message;
            errorDiv.classList.remove('hidden');
            setTimeout(() => {
                errorDiv.classList.add('hidden');
            }, 5000);
        }
    },

    confirmAddAsset() {
        // Prevent duplicate additions
        if (this.isAdding) {
            console.log('Already adding asset, ignoring duplicate click');
            return;
        }

        if (!this.extractedAsset) {
            console.log('No extracted asset to add');
            return;
        }

        // Validate that value is provided
        if (!this.extractedAsset.value || this.extractedAsset.value === 0) {
            this.showError('Please enter a value for the asset before adding it to the portfolio.');
            this.showEditForm();
            return;
        }

        // Set flag to prevent duplicates
        this.isAdding = true;

        // Disable button to prevent multiple clicks
        const confirmBtn = document.getElementById('confirmAddAssetBtn');
        if (confirmBtn) {
            confirmBtn.disabled = true;
            confirmBtn.textContent = 'Adding...';
        }

        try {
            // Add asset to portfolio (only once)
            AssetManager.addAsset(this.extractedAsset);

            // Show success message
            const successMsg = `✓ ${this.extractedAsset.name} (${Utils.formatCurrency(this.extractedAsset.value)}) added to portfolio successfully!`;
            this.showSuccess(successMsg);
            
            // Reset form after a short delay
            setTimeout(() => {
                this.resetForm();
                this.isAdding = false;
            }, 2000);
        } catch (error) {
            console.error('Error adding asset:', error);
            this.isAdding = false;
            if (confirmBtn) {
                confirmBtn.disabled = false;
                confirmBtn.textContent = 'Add to Portfolio';
            }
        }
    },

    showSuccess(message) {
        const errorDiv = document.getElementById('assetErrorMessage');
        if (errorDiv) {
            errorDiv.className = 'mt-4 p-3 bg-green-500/10 text-green-700 text-sm rounded-md border border-green-500/20';
            errorDiv.textContent = message;
            errorDiv.classList.remove('hidden');
            setTimeout(() => {
                errorDiv.classList.add('hidden');
                errorDiv.className = 'hidden mt-4 p-3 bg-destructive/10 text-destructive text-sm rounded-md border border-destructive/20';
            }, 3000);
        }
    },

    cancelAddAsset() {
        this.resetForm();
    },

    resetForm() {
        this.currentFile = null;
        this.extractedAsset = null;
        this.isAdding = false;
        
        const fileInput = document.getElementById('assetFileInput');
        const preview = document.getElementById('extractedAssetPreview');
        const processing = document.getElementById('assetProcessingStatus');
        const errorMsg = document.getElementById('assetErrorMessage');
        const confirmBtn = document.getElementById('confirmAddAssetBtn');
        
        if (fileInput) fileInput.value = '';
        if (preview) preview.classList.add('hidden');
        if (processing) processing.classList.add('hidden');
        if (errorMsg) errorMsg.classList.add('hidden');
        if (confirmBtn) {
            confirmBtn.disabled = false;
            confirmBtn.textContent = 'Add to Portfolio';
        }
    },

    showEditForm() {
        if (!this.extractedAsset) return;

        // Create a simple edit form
        const infoContainer = document.getElementById('extractedAssetInfo');
        if (!infoContainer) return;

        infoContainer.innerHTML = `
            <div class="space-y-3">
                <div>
                    <label class="text-xs text-muted-foreground mb-1 block">Asset Name</label>
                    <input type="text" id="editAssetName" value="${this.extractedAsset.name}" class="w-full px-3 py-2 border rounded-md text-sm">
                </div>
                <div>
                    <label class="text-xs text-muted-foreground mb-1 block">Location</label>
                    <input type="text" id="editAssetLocation" value="${this.extractedAsset.location || ''}" class="w-full px-3 py-2 border rounded-md text-sm" placeholder="City, State">
                </div>
                <div>
                    <label class="text-xs text-muted-foreground mb-1 block">Value (₹)</label>
                    <input type="number" id="editAssetValue" value="${this.extractedAsset.value || ''}" class="w-full px-3 py-2 border rounded-md text-sm" placeholder="Enter value">
                </div>
            </div>
        `;

        // Update save button to save edits
        const confirmBtn = document.getElementById('confirmAddAssetBtn');
        if (confirmBtn) {
            confirmBtn.textContent = 'Save & Add';
            confirmBtn.onclick = () => {
                this.saveEdits();
            };
        }
    },

    saveEdits() {
        if (!this.extractedAsset) return;

        const nameInput = document.getElementById('editAssetName');
        const locationInput = document.getElementById('editAssetLocation');
        const valueInput = document.getElementById('editAssetValue');

        if (nameInput) this.extractedAsset.name = nameInput.value || this.extractedAsset.name;
        if (locationInput) this.extractedAsset.location = locationInput.value || null;
        if (valueInput) this.extractedAsset.value = parseFloat(valueInput.value) || this.extractedAsset.value;

        // Show updated preview
        this.showExtractedAsset(this.extractedAsset);

        // Restore confirm button
        const confirmBtn = document.getElementById('confirmAddAssetBtn');
        if (confirmBtn) {
            confirmBtn.textContent = 'Add to Portfolio';
            confirmBtn.onclick = () => {
                this.confirmAddAsset();
            };
        }
    }
};

