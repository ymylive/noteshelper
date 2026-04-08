import 'package:dio/dio.dart';
import 'package:noteshelper/core/config/app_config.dart';
import 'package:noteshelper/core/network/api_client.dart';
import 'package:noteshelper/core/network/api_endpoints.dart';
import 'package:noteshelper/models/note.dart';
import 'package:noteshelper/models/mind_map_node.dart';

class RecognitionResult {
  final Note note;
  final MindMapNode? mindMap;

  const RecognitionResult({required this.note, this.mindMap});
}

class RecognitionService {
  final ApiClient _client = ApiClient();

  /// Upload an image for AI recognition and receive a structured note + mind map.
  Future<RecognitionResult> recognizeImage({
    required String filePath,
    required String provider,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'provider': provider,
    });

    final response = await _client.dio.post(
      ApiEndpoints.recognize,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        receiveTimeout: Duration(milliseconds: AppConfig.uploadTimeout),
        sendTimeout: Duration(milliseconds: AppConfig.uploadTimeout),
      ),
    );

    final data = response.data as Map<String, dynamic>;
    final note = Note.fromJson(data['note'] as Map<String, dynamic>);

    MindMapNode? mindMap;
    if (data['mind_map'] != null) {
      mindMap = MindMapNode.fromJson(data['mind_map'] as Map<String, dynamic>);
    }

    return RecognitionResult(note: note, mindMap: mindMap);
  }

  /// Get available AI providers.
  Future<List<String>> getProviders() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.recognitionProviders);
      final data = response.data;
      if (data is List) {
        return data.map((e) => e.toString()).toList();
      }
      if (data is Map && data['providers'] is List) {
        return (data['providers'] as List).map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return ['openai', 'gemini', 'claude'];
  }
}
