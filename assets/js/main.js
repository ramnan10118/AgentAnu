// Main Application Initialization
function initializeApp() {
    console.log('Initializing app...');
    
    try {
        // Initialize Asset Manager
        if (typeof AssetManager !== 'undefined') {
            AssetManager.init();
        } else {
            console.error('AssetManager is not defined!');
            return;
        }

        // Initialize Document Manager
        if (typeof DocumentManager !== 'undefined') {
            DocumentManager.init();
        }

        // Initialize Asset Upload
        if (typeof AssetUpload !== 'undefined') {
            AssetUpload.init();
        }

        // Load mock data for visualization
        const assetData = AssetManager.getAssetData();
        console.log('Got asset data:', assetData);
        
        if (typeof Assets !== 'undefined') {
            Assets.updateAssetData(assetData);
        } else {
            console.error('Assets object is not defined!');
        }

        // Setup flip card interactions - delay slightly to ensure DOM is ready
        if (typeof Components !== 'undefined') {
            setTimeout(() => {
                Components.setupFlipCards();
            }, 100);
            
            // Setup sticky net worth - needs to wait for layout
            setTimeout(() => {
                Components.setupStickyNetWorth();
            }, 500);
            
            // Setup collapsible cards with a longer delay to ensure all content is loaded
            setTimeout(() => {
                Components.setupCollapsibleCards();
            }, 300);
        }
        
        console.log('App initialization complete');
    } catch (error) {
        console.error('Error during initialization:', error);
    }
}

// Run immediately if DOM is ready, otherwise wait
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeApp);
} else {
    // DOM is already ready
    initializeApp();
}

