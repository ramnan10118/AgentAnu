// Main Application Initialization
document.addEventListener('DOMContentLoaded', () => {
    // Initialize Document Manager
    DocumentManager.init();

    // Load mock data for visualization
    // TODO: Replace with Account Aggregator API call
    // Example: fetchAccountAggregatorData().then(Assets.updateAssetData);
    Assets.updateAssetData(mockAssetData);

    // Setup flip card interactions
    Components.setupFlipCards();

    // Setup sticky net worth card
    Components.setupStickyNetWorth();
});

