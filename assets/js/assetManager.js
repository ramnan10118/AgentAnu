// Asset Manager - Handles dynamic asset additions
const AssetManager = {
    // Global asset data store
    assetData: null,

    init() {
        // Initialize with mock data
        if (typeof mockAssetData === 'undefined') {
            console.error('mockAssetData is not defined! Make sure data.js is loaded before assetManager.js');
            return;
        }
        this.assetData = JSON.parse(JSON.stringify(mockAssetData));
        console.log('AssetManager initialized with data:', this.assetData);
    },

    // Add a new asset extracted from document
    addAsset(assetInfo) {
        if (!this.assetData) {
            this.init();
        }

        // Ensure assets object exists
        if (!this.assetData.assets) {
            this.assetData.assets = {
                total: 0,
                count: 0,
                details: []
            };
        }

        // Ensure asset has an ID
        if (!assetInfo.id) {
            assetInfo.id = Date.now().toString() + '-' + Math.random().toString(36).substr(2, 9);
        }

        // Check for duplicate assets (same ID)
        const existingAsset = this.assetData.assets.details.find(a => a.id === assetInfo.id);
        if (existingAsset) {
            console.warn('Asset with this ID already exists, skipping duplicate:', assetInfo.id);
            return existingAsset;
        }

        // Ensure value is a number
        assetInfo.value = assetInfo.value || 0;

        console.log('Adding asset:', assetInfo);

        // Add the new asset
        this.assetData.assets.details.push(assetInfo);
        
        // Update totals
        this.assetData.assets.total += assetInfo.value;
        this.assetData.assets.count = this.assetData.assets.details.length;

        console.log('Total assets after addition:', this.assetData.assets.count);

        // Update the UI
        Assets.updateAssetData(this.assetData);

        return assetInfo;
    },

    // Get current asset data
    getAssetData() {
        if (!this.assetData) {
            this.init();
        }
        return this.assetData;
    },

    // Remove an asset
    removeAsset(assetId) {
        if (!this.assetData || !this.assetData.assets) return;

        const asset = this.assetData.assets.details.find(a => a.id === assetId);
        if (asset) {
            this.assetData.assets.total -= asset.value || 0;
            this.assetData.assets.details = this.assetData.assets.details.filter(a => a.id !== assetId);
            this.assetData.assets.count = this.assetData.assets.details.length;

            // Update the UI
            Assets.updateAssetData(this.assetData);
        }
    }
};

