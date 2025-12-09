import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/asset_model.dart';
import '../services/api_service.dart';

class AssetsState {
  final List<AssetModel> assets;
  final double totalNetWorth;
  final bool isLoading;
  final String? error;
  final bool hasConsented;

  AssetsState({
    this.assets = const [],
    this.totalNetWorth = 0.0,
    this.isLoading = false,
    this.error,
    this.hasConsented = false,
  });

  AssetsState copyWith({
    List<AssetModel>? assets,
    double? totalNetWorth,
    bool? isLoading,
    String? error,
    bool? hasConsented,
  }) {
    return AssetsState(
      assets: assets ?? this.assets,
      totalNetWorth: totalNetWorth ?? this.totalNetWorth,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasConsented: hasConsented ?? this.hasConsented,
    );
  }
}

class AssetsNotifier extends StateNotifier<AssetsState> {
  final ApiService _apiService = ApiService();

  AssetsNotifier() : super(AssetsState());

  Future<bool> grantConsent() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.grantConsent(true);
      if (response['success'] == true) {
        state = state.copyWith(hasConsented: true, isLoading: false);
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Consent failed');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> fetchAssets() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.fetchAssets();
      if (response['success'] == true) {
        final assetsList = (response['assets'] as List)
            .map((json) => AssetModel.fromJson(json))
            .toList();
        final netWorth = (response['totalNetWorth'] as num).toDouble();
        state = state.copyWith(
          assets: assetsList,
          totalNetWorth: netWorth,
          isLoading: false,
        );
        return true;
      }
      // Capture the actual error message from backend
      final errorMessage = response['message'] ?? 'Failed to fetch assets';
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> getAssets() async {
    // Don't show loading if we already have assets
    final showLoading = state.assets.isEmpty;
    state = state.copyWith(isLoading: showLoading, error: null);
    try {
      final response = await _apiService.getAssets();
      if (response['success'] == true) {
        final assetsList = (response['assets'] as List)
            .map((json) => AssetModel.fromJson(json))
            .toList();
        final netWorth = (response['totalNetWorth'] as num).toDouble();
        state = state.copyWith(
          assets: assetsList,
          totalNetWorth: netWorth,
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> getRevealedAssets(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.getRevealedAssets(userId);
      if (response['success'] == true) {
        final assetsList = (response['assets'] as List)
            .map((json) => AssetModel.fromJson(json))
            .toList();
        final netWorth = (response['totalNetWorth'] as num).toDouble();
        state = state.copyWith(
          assets: assetsList,
          totalNetWorth: netWorth,
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    state = AssetsState();
  }
}

final assetsProvider = StateNotifierProvider<AssetsNotifier, AssetsState>((ref) {
  return AssetsNotifier();
});

