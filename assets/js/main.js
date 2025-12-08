// Main Application Initialization
document.addEventListener('DOMContentLoaded', () => {
    // Initialize Asset Manager
    AssetManager.init();

    // Initialize Document Manager
    DocumentManager.init();

    // Initialize Asset Upload
    AssetUpload.init();

    // Load mock data for visualization
    // TODO: Replace with Account Aggregator API call
    // Example: fetchAccountAggregatorData().then(Assets.updateAssetData);
    Assets.updateAssetData(AssetManager.getAssetData());

    // Setup flip card interactions
    Components.setupFlipCards();

    // Setup sticky net worth card
    Components.setupStickyNetWorth();
});

