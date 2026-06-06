import 'package:flutter/foundation.dart';
import '../models/game.dart';
import '../models/game_status.dart';
import '../database/database_helper.dart';

class GamesProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Game> _games = [];
  String _searchQuery = '';
  GameStatus? _statusFilter;
  bool _isLoading = false;
  String? _error;

  List<Game> get games => _filteredGames;
  List<Game> get allGames => _games;
  String get searchQuery => _searchQuery;
  GameStatus? get statusFilter => _statusFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Game> get _filteredGames {
    var result = List<Game>.from(_games);

    if (_statusFilter != null) {
      result = result.where((g) => g.status == _statusFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((g) {
        return g.title.toLowerCase().contains(query) ||
            g.platform.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  int get totalGames => _games.length;
  int get playingCount => _games.where((g) => g.status == GameStatus.playing).length;
  int get completedCount => _games.where((g) => g.status == GameStatus.completed).length;
  int get backlogCount => _games.where((g) => g.status == GameStatus.backlog).length;
  int get droppedCount => _games.where((g) => g.status == GameStatus.dropped).length;

  Future<void> loadGames() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _games = await _db.getAllGames();
    } catch (e) {
      _error = 'Failed to load games: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addGame(Game game) async {
    try {
      final id = await _db.insertGame(game);
      final newGame = game.copyWith(id: id);
      _games.insert(0, newGame);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add game: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateGame(Game game) async {
    try {
      await _db.updateGame(game);
      final index = _games.indexWhere((g) => g.id == game.id);
      if (index != -1) {
        _games[index] = game;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to update game: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGame(int id) async {
    try {
      await _db.deleteGame(id);
      _games.removeWhere((g) => g.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete game: $e';
      notifyListeners();
      return false;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(GameStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
