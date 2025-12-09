# Merge Conflict Summary - Changes Lost After Main Branch Pull

## ✅ What's Still There:
1. **Loans in mock data** - Backend still has loan data with EMI, remaining months, etc.
2. **Loans category support** - AssetCategory.loans enum exists and is used
3. **Basic loan display** - Loans show up in the category cards

## ❌ What's Missing/Changed:

### 1. **Flip Card Functionality** 
- **Status**: Completely removed
- **Previous**: Cards had flip animation showing summary stats on back
- **Current**: Simple static cards with no flip interaction
- **Location**: `main_app/lib/widgets/asset_category_card.dart` - needs flip functionality

### 2. **OCR Document Upload**
- **Status**: Missing from API service
- **Missing Methods**:
  - `extractAssetFromBytes()` - OCR endpoint
  - `addManualAsset()` - Manual asset addition
- **Location**: `main_app/lib/services/api_service.dart` - needs these methods added

### 3. **Asset Model Loan Support**
- **Status**: Missing loan-specific methods
- **Missing**:
  - `case 'loan'` in `assetTypeLabel` getter
  - `isLiability` getter
- **Location**: `main_app/lib/models/asset_model.dart`

### 4. **ShadCN UI Design System**
- **Status**: Replaced with different color scheme
- **Previous**: ShadCN colors, subtle shadows, minimal design
- **Current**: Different color palette (blue theme)
- **Location**: Dashboard and widgets

### 5. **Compact Card Layout**
- **Status**: Reverted to 2 columns
- **Previous**: 3-column grid, compact spacing, reduced padding
- **Current**: 2-column grid with more spacing
- **Location**: `main_app/lib/screens/dashboard/dashboard_screen.dart` line 338

### 6. **Sticky Net Worth Header**
- **Status**: Need to verify
- **Previous**: SliverPersistentHeader with smooth transition
- **Location**: Check `main_app/lib/widgets/net_worth_card.dart`

### 7. **Loan Detail Cards**
- **Status**: Need to verify if detailed loan cards exist
- **Previous**: Full loan details with EMI, remaining months, progress bar
- **Location**: Check collapsible sections

## 🔧 Files That Need Restoration:

1. **main_app/lib/services/api_service.dart**
   - Add `extractAssetFromBytes()` method
   - Add `addManualAsset()` method
   - Fix Content-Type header issue for multipart

2. **main_app/lib/models/asset_model.dart**
   - Add `case 'loan'` to `assetTypeLabel`
   - Add `isLiability` getter

3. **main_app/lib/widgets/asset_category_card.dart**
   - Add flip card functionality
   - Restore compact design (3 columns, reduced padding)

4. **main_app/lib/screens/dashboard/dashboard_screen.dart**
   - Add OCR upload section
   - Restore ShadCN design system colors
   - Update grid to 3 columns

5. **main_app/lib/widgets/net_worth_card.dart**
   - Verify sticky header functionality

## 📝 Priority Order:
1. **High**: OCR upload functionality (document upload feature)
2. **High**: Loan detail cards (EMI, remaining months display)
3. **Medium**: Flip card functionality
4. **Medium**: Compact card layout (3 columns)
5. **Low**: ShadCN design system (cosmetic)

