import 'dart:io';
import 'package:dio/dio.dart';
import 'package:nirbhaya/core/network/api_client.dart';
import 'package:nirbhaya/core/network/api_endpoints.dart';
import 'package:nirbhaya/shared/models/api_response.dart';

class UploadsApi {
  final ApiClient apiClient;

  UploadsApi(this.apiClient);

  Future<ApiResponse<dynamic>> uploadFile(File file) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    return apiClient.post<dynamic>(
      ApiEndpoints.uploads,
      data: formData,
    );
  }

  Future<ApiResponse<dynamic>> getUploads() async {
    return apiClient.get<dynamic>(ApiEndpoints.uploads);
  }

  Future<ApiResponse<dynamic>> deleteUpload(String id) async {
    return apiClient.post<dynamic>('${ApiEndpoints.uploads}/$id/delete');
  }
}
