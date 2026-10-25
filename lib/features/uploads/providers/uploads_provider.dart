import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirbhaya/features/auth/providers/auth_providers.dart'; // contains apiClientProvider
import 'package:nirbhaya/features/uploads/data/uploads_api.dart';
import 'package:nirbhaya/features/uploads/domain/upload_model.dart';

final uploadsApiProvider = Provider<UploadsApi>((ref) {
  return UploadsApi(ref.watch(apiClientProvider));
});

class UploadsNotifier extends StateNotifier<AsyncValue<List<UploadedMedia>>> {
  final UploadsApi _api;

  UploadsNotifier(this._api) : super(const AsyncValue.loading()) {
    loadUploads();
  }

  Future<void> loadUploads() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getUploads();
      if (response.success && response.data != null) {
        final List<dynamic> data = response.data;
        final uploads = data.map((e) => UploadedMedia.fromJson(e)).toList();
        state = AsyncValue.data(uploads);
      } else {
        final msg = response.message.isNotEmpty ? response.message : 'Failed to load uploads';
        state = AsyncValue.error(msg, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> uploadFile(String filePath) async {
    try {
      final file = File(filePath);
      final response = await _api.uploadFile(file);
      if (response.success) {
        // Reload uploads to get the new list
        await loadUploads();
      } else {
        throw Exception(response.message.isNotEmpty ? response.message : 'Failed to upload file');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUpload(String id) async {
    try {
      final response = await _api.deleteUpload(id);
      if (response.success) {
        await loadUploads();
      } else {
        throw Exception(response.message.isNotEmpty ? response.message : 'Failed to delete upload');
      }
    } catch (e) {
      rethrow;
    }
  }
}

final uploadsProvider = StateNotifierProvider<UploadsNotifier, AsyncValue<List<UploadedMedia>>>((ref) {
  return UploadsNotifier(ref.watch(uploadsApiProvider));
});
