import 'package:noteshelper/core/network/api_client.dart';
import 'package:noteshelper/core/network/api_endpoints.dart';
import 'package:noteshelper/models/note.dart';
import 'package:noteshelper/models/mind_map_node.dart';

class NoteService {
  final ApiClient _client = ApiClient();

  Future<List<Note>> getNotes({int page = 1, int limit = 20, String? search}) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await _client.dio.get(
      ApiEndpoints.notes,
      queryParameters: queryParams,
    );

    final data = response.data;
    List<dynamic> items;

    if (data is Map<String, dynamic>) {
      items = data['items'] as List<dynamic>? ?? data['notes'] as List<dynamic>? ?? [];
    } else if (data is List) {
      items = data;
    } else {
      items = [];
    }

    return items
        .map((json) => Note.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Note> getNote(String id) async {
    final response = await _client.dio.get(ApiEndpoints.note(id));
    return Note.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Note> updateNote(String id, {String? title, String? contentMarkdown}) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (contentMarkdown != null) data['content_markdown'] = contentMarkdown;

    final response = await _client.dio.patch(
      ApiEndpoints.note(id),
      data: data,
    );
    return Note.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteNote(String id) async {
    await _client.dio.delete(ApiEndpoints.note(id));
  }

  Future<MindMapNode?> getMindMap(String noteId) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.noteMindMap(noteId));
      if (response.data != null) {
        return MindMapNode.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  Future<void> updateMindMap(String noteId, MindMapNode root) async {
    await _client.dio.put(
      ApiEndpoints.noteMindMap(noteId),
      data: root.toJson(),
    );
  }
}
