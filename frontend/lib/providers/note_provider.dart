import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noteshelper/models/note.dart';
import 'package:noteshelper/models/mind_map_node.dart';
import 'package:noteshelper/services/note_service.dart';
import 'package:noteshelper/services/recognition_service.dart';

// ---------- Service Providers ----------

final noteServiceProvider = Provider<NoteService>((ref) => NoteService());
final recognitionServiceProvider = Provider<RecognitionService>((ref) => RecognitionService());

// ---------- Notes List ----------

class NotesListState {
  final List<Note> notes;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String searchQuery;

  const NotesListState({
    this.notes = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.searchQuery = '',
  });

  NotesListState copyWith({
    List<Note>? notes,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? searchQuery,
    bool clearError = false,
  }) {
    return NotesListState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class NotesListNotifier extends StateNotifier<NotesListState> {
  final NoteService _noteService;

  NotesListNotifier(this._noteService) : super(const NotesListState());

  Future<void> loadNotes({bool refresh = false}) async {
    if (state.isLoading) return;

    final page = refresh ? 1 : state.currentPage;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final notes = await _noteService.getNotes(
        page: page,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );

      state = state.copyWith(
        notes: refresh ? notes : [...state.notes, ...notes],
        isLoading: false,
        currentPage: page + 1,
        hasMore: notes.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load notes. Please try again.',
      );
    }
  }

  Future<void> search(String query) async {
    state = NotesListState(searchQuery: query);
    await loadNotes(refresh: true);
  }

  Future<void> deleteNote(String id) async {
    try {
      await _noteService.deleteNote(id);
      state = state.copyWith(
        notes: state.notes.where((n) => n.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete note.');
    }
  }

  void addNote(Note note) {
    state = state.copyWith(notes: [note, ...state.notes]);
  }

  void updateNoteInList(Note updated) {
    state = state.copyWith(
      notes: state.notes.map((n) => n.id == updated.id ? updated : n).toList(),
    );
  }
}

final notesListProvider =
    StateNotifierProvider<NotesListNotifier, NotesListState>((ref) {
  return NotesListNotifier(ref.read(noteServiceProvider));
});

// ---------- Single Note ----------

final noteDetailProvider =
    FutureProvider.family<Note, String>((ref, noteId) async {
  final service = ref.read(noteServiceProvider);
  return service.getNote(noteId);
});

// ---------- Mind Map ----------

final mindMapProvider =
    FutureProvider.family<MindMapNode?, String>((ref, noteId) async {
  final service = ref.read(noteServiceProvider);
  final root = await service.getMindMap(noteId);
  if (root != null) {
    MindMapNode.layoutTree(root);
  }
  return root;
});

// ---------- Recognition ----------

class RecognitionState {
  final bool isProcessing;
  final String? statusText;
  final RecognitionResult? result;
  final String? error;

  const RecognitionState({
    this.isProcessing = false,
    this.statusText,
    this.result,
    this.error,
  });
}

class RecognitionNotifier extends StateNotifier<RecognitionState> {
  final RecognitionService _service;

  RecognitionNotifier(this._service) : super(const RecognitionState());

  Future<RecognitionResult?> recognize(String filePath, String provider) async {
    state = const RecognitionState(
      isProcessing: true,
      statusText: 'Uploading image...',
    );

    try {
      state = const RecognitionState(
        isProcessing: true,
        statusText: 'AI is analyzing your image...',
      );

      final result = await _service.recognizeImage(
        filePath: filePath,
        provider: provider,
      );

      state = RecognitionState(
        isProcessing: false,
        statusText: 'Done!',
        result: result,
      );

      return result;
    } catch (e) {
      state = RecognitionState(
        isProcessing: false,
        error: 'Recognition failed. Please try again.',
      );
      return null;
    }
  }

  void reset() {
    state = const RecognitionState();
  }
}

final recognitionProvider =
    StateNotifierProvider<RecognitionNotifier, RecognitionState>((ref) {
  return RecognitionNotifier(ref.read(recognitionServiceProvider));
});
