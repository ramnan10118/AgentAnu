import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/designation_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class NokState {
  final DesignationModel? designation;
  final List<DesignationModel> designations;
  final bool isLoading;
  final String? error;
  final bool hasDesignation;

  NokState({
    this.designation,
    this.designations = const [],
    this.isLoading = false,
    this.error,
    this.hasDesignation = false,
  });

  NokState copyWith({
    DesignationModel? designation,
    List<DesignationModel>? designations,
    bool? isLoading,
    String? error,
    bool? hasDesignation,
  }) {
    return NokState(
      designation: designation ?? this.designation,
      designations: designations ?? this.designations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasDesignation: hasDesignation ?? this.hasDesignation,
    );
  }
}

class NokNotifier extends StateNotifier<NokState> {
  final ApiService _apiService = ApiService();

  NokNotifier() : super(NokState());

  Future<bool> designateNok({
    required String nokMobile,
    required String nokName,
    required String relationship,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.designateNok(
        nokMobile: nokMobile,
        nokName: nokName,
        relationship: relationship,
      );
      if (response['success'] == true) {
        state = state.copyWith(
          designation: DesignationModel.fromJson(response['designation']),
          hasDesignation: true,
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Designation failed');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> getNokStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.getNokStatus();
      if (response['success'] == true) {
        final hasDesignation = response['hasDesignation'] as bool;
        if (hasDesignation && response['designation'] != null) {
          state = state.copyWith(
            designation: DesignationModel.fromJson(response['designation']),
            hasDesignation: true,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            hasDesignation: false,
            isLoading: false,
          );
        }
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> getDesignations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.getNokDesignations();
      if (response['success'] == true) {
        final designationsList = (response['designations'] as List)
            .map((json) => DesignationModel.fromJson(json))
            .toList();
        state = state.copyWith(
          designations: designationsList,
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

  Future<bool> acceptDesignation(String designationId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.acceptDesignation(designationId);
      if (response['success'] == true) {
        // Emit socket event immediately after API success
        SocketService().emitNokAccept(designationId);

        // Update the designation in the list
        await getDesignations();
        state = state.copyWith(isLoading: false);
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Failed to accept');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> rejectDesignation(String designationId, String reason) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.rejectDesignation(designationId, reason);
      if (response['success'] == true) {
        await getDesignations();
        state = state.copyWith(isLoading: false);
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Failed to reject');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void updateDesignationStatus(DesignationModel designation) {
    state = state.copyWith(designation: designation);
  }

  void reset() {
    state = NokState();
  }
}

final nokProvider = StateNotifierProvider<NokNotifier, NokState>((ref) {
  return NokNotifier();
});

