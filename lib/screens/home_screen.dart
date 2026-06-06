import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_status.dart';
import '../providers/games_provider.dart';
import '../widgets/game_card.dart';
import 'add_edit_game_screen.dart';
import 'game_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() => _isSearching = true);
    Future.microtask(() => _searchFocusNode.requestFocus());
  }

  void _stopSearch() {
    setState(() => _isSearching = false);
    _searchController.clear();
    context.read<GamesProvider>().setSearchQuery('');
    _searchFocusNode.unfocus();
  }

  void _navigateToAddGame() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddEditGameScreen()),
    );
  }

  void _navigateToDetail(int index) async {
    final provider = context.read<GamesProvider>();
    final game = provider.games[index];
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameDetailScreen(game: game)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _FilterChipsRow(),
          Expanded(child: _GamesList(onTap: _navigateToDetail)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddGame,
        icon: const Icon(Icons.add),
        label: const Text('Add Game'),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    if (_isSearching) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _stopSearch,
        ),
        title: Consumer<GamesProvider>(
          builder: (_, provider, __) => TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search games...',
              border: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        provider.setSearchQuery('');
                      },
                    )
                  : null,
            ),
            style: Theme.of(context).textTheme.titleMedium,
            onChanged: provider.setSearchQuery,
          ),
        ),
      );
    }

    return AppBar(
      title: const Text('My Games'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _startSearch,
          tooltip: 'Search',
        ),
      ],
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GamesProvider>(
      builder: (_, provider, __) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _buildChip(
                context: context,
                label: 'All (${provider.totalGames})',
                isSelected: provider.statusFilter == null,
                onTap: () => provider.setStatusFilter(null),
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              ...GameStatus.values.map((status) {
                final count = _countForStatus(provider, status);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildChip(
                    context: context,
                    label: '${status.label} ($count)',
                    isSelected: provider.statusFilter == status,
                    onTap: () => provider.setStatusFilter(
                      provider.statusFilter == status ? null : status,
                    ),
                    color: status.color,
                    icon: status.icon,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  int _countForStatus(GamesProvider provider, GameStatus status) {
    switch (status) {
      case GameStatus.playing:
        return provider.playingCount;
      case GameStatus.completed:
        return provider.completedCount;
      case GameStatus.backlog:
        return provider.backlogCount;
      case GameStatus.dropped:
        return provider.droppedCount;
    }
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Theme.of(context).colorScheme.outline.withOpacity(0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: isSelected ? color : Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GamesList extends StatelessWidget {
  final void Function(int index) onTap;

  const _GamesList({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<GamesProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 12),
                Text(provider.error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    provider.clearError();
                    provider.loadGames();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final games = provider.games;

        if (games.isEmpty) {
          return _EmptyState(
            isFiltered: provider.statusFilter != null || provider.searchQuery.isNotEmpty,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 88),
          itemCount: games.length,
          itemBuilder: (context, index) {
            return GameCard(
              game: games[index],
              onTap: () => onTap(index),
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isFiltered;

  const _EmptyState({required this.isFiltered});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFiltered ? Icons.search_off : Icons.videogame_asset_outlined,
              size: 72,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered ? 'No games match your filter' : 'Your library is empty',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Try adjusting your search or status filter'
                  : 'Tap the + button to add your first game',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
