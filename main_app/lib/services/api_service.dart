import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'storage_service.dart';

class ApiService {
  late final Dio _dio;
  final StorageService _storage = StorageService();

  // Singleton
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.timeout,
      receiveTimeout: ApiConfig.timeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Request interceptor to add token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print('🌐 ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('❌ ${error.response?.statusCode} ${error.requestOptions.path}');
        print('Error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  // Auth endpoints
  Future<Map<String, dynamic>> sendOtp(String mobile) async {
    final response = await _dio.post(ApiConfig.sendOtp, data: {
      'mobile': mobile,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyOtp(String mobile, String otp) async {
    final response = await _dio.post(ApiConfig.verifyOtp, data: {
      'mobile': mobile,
      'otp': otp,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> validatePan(String pan) async {
    final response = await _dio.post(ApiConfig.validatePan, data: {
      'pan': pan,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _dio.get(ApiConfig.me);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> logout() async {
    final response = await _dio.post(ApiConfig.logout);
    return response.data as Map<String, dynamic>;
  }

  // Assets endpoints
  Future<Map<String, dynamic>> grantConsent(bool consented) async {
    final response = await _dio.post(ApiConfig.assetsConsent, data: {
      'consented': consented,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchAssets() async {
    final response = await _dio.get(ApiConfig.assetsFetch);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAssets() async {
    final response = await _dio.get(ApiConfig.assets);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getRevealedAssets(String userId) async {
    final response = await _dio.get('${ApiConfig.assetsRevealed}/$userId');
    return response.data as Map<String, dynamic>;
  }

  // NOK endpoints
  Future<Map<String, dynamic>> designateNok({
    required String nokMobile,
    required String nokName,
    required String relationship,
  }) async {
    final response = await _dio.post(ApiConfig.nokDesignate, data: {
      'nokMobile': nokMobile,
      'nokName': nokName,
      'relationship': relationship,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getNokStatus() async {
    final response = await _dio.get(ApiConfig.nokStatus);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getNokDesignations() async {
    final response = await _dio.get(ApiConfig.nokDesignations);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> acceptDesignation(String designationId) async {
    final response = await _dio.post('${ApiConfig.nokAccept}/$designationId');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> rejectDesignation(
    String designationId,
    String reason,
  ) async {
    final response = await _dio.post(
      '${ApiConfig.nokReject}/$designationId',
      data: {'reason': reason},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> revokeNok() async {
    final response = await _dio.delete(ApiConfig.nokRevoke);
    return response.data as Map<String, dynamic>;
  }

  // Death certificate endpoints
  Future<Map<String, dynamic>> uploadDeathCertificate({
    required String accountHolderMobile,
    required String fileName,
    required String fileData,
  }) async {
    final response = await _dio.post(ApiConfig.deathUpload, data: {
      'accountHolderMobile': accountHolderMobile,
      'fileName': fileName,
      'fileData': fileData,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDeathStatus(String accountHolderId) async {
    final response = await _dio.get('${ApiConfig.deathStatus}/$accountHolderId');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getClaimsGuidance(String assetType) async {
    final response = await _dio.get('${ApiConfig.deathClaimsGuidance}/$assetType');
    return response.data as Map<String, dynamic>;
  }

  // OCR endpoints
  Future<Map<String, dynamic>> extractAssetFromDocument(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post(
      '/api/ocr/extract-asset',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> extractAssetFromBytes(
    List<int> fileBytes,
    String fileName,
  ) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        fileBytes,
        filename: fileName,
      ),
    });
    final response = await _dio.post(
      '/api/ocr/extract-asset',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
    return response.data as Map<String, dynamic>;
  }

  // Manual asset endpoints
  Future<Map<String, dynamic>> addManualAsset({
    required String type,
    required String name,
    String? location,
    required double value,
    String? provider,
    String? accountNumber,
    Map<String, dynamic>? details,
  }) async {
    final response = await _dio.post('/api/assets/manual', data: {
      'type': type,
      'name': name,
      'location': location,
      'value': value,
      'provider': provider ?? name,
      'accountNumber': accountNumber,
      'details': details ?? {},
    });
    return response.data as Map<String, dynamic>;
  }
}

