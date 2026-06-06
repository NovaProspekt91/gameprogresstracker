import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../models/game.dart';
import '../models/game_status.dart';
import '../providers/games_provider.dart';

class AddEditGameScreen extends StatefulWidget {
  final Game? game;

  const AddEditGameScreen({super.key, this.game});

  @override
  State<AddEditGameScreen> createState() => _AddEditGameScreenState();
}

class _AddEditGameScreenState extends State<AddEditGameScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _platformController;
  late final TextEditingController _notesController;

  late GameStatus _status;
  late double _hoursPlayed;
  late int _completionPercent;
  late double _rating;

  bool _isSaving = false;

  bool get _isEditing => widget.game != null;

  @override
  void initState() {
    super.initState();
    final game = widget.game;
    _titleController = TextEditingController(text: game?.title ?? '');
    _platformController = TextEditingController(text: game?.platform ?? '');
    _notesController = TextEditingController(text: game?.notes ?? '');
    _status = game?.status ?? GameStatus.backlog;
    _hoursPlayed = game?.hoursPlayed ?? 0.0;
    _completionPercent = game?.completionPercent ?? 0;
    _rating = game?.rating ?? 0.0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _platformController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<GamesProvider>();
    bool success;

    if (_isEditing) {
      final updated = widget.game!.copyWith(
        title: _titleController.text.trim(),
        platform: _platformController.text.trim(),
        status: _status,
        hoursPlayed: _hoursPlayed,
        completionPercent: _completionPercent,
        rating: _rating,
        notes: _notesController.text.trim(),
      );
      success = await provider.updateGame(updated);
    } else {
      final newGame = Game(
        title: _titleController.text.trim(),
        platform: _platformController.text.trim(),
        status: _status,
        hoursPlayed: _hoursPlayed,
        completionPercent: _completionPercent,
        rating: _rating,
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
      );
      success = await provider.addGame(newGame);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'An error occurred'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      provider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Game' : 'Add Game'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader(title: 'Game Info'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter game title',
                prefixIcon: Icon(Icons.videogame_asset),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _platformController,
              decoration: const InputDecoration(
                labelText: 'Platform',
                hintText: 'e.g. PC, PS5, Nintendo Switch',
                prefixIcon: Icon(Icons.devices),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Status'),
            const SizedBox(height: 12),
            _StatusSelector(
              selected: _status,
              onChanged: (status) => setState(() => _status = status),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Progress'),
            const SizedBox(height: 12),
            _SliderField(
              label: 'Hours Played',
              value: _hoursPlayed,
              min: 0,
              max: 500,
              divisions: 500,
              displayValue: _formatHours(_hoursPlayed),
              onChanged: (value) => setState(() => _hoursPlayed = value),
            ),
            const SizedBox(height: 12),
            _SliderField(
              label: 'Completion',
              value: _completionPercent.toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              displayValue: '$_completionPercent%',
              onChanged: (value) =>
                  setState(() => _completionPercent = value.round()),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Rating'),
            const SizedBox(height: 12),
            Center(
              child: Column(
                children: [
                  RatingBar.builder(
                    initialRating: _rating,
                    minRating: 0,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 40,
                    glow: false,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Color(0xFFFFD700),
                    ),
                    unratedColor: theme.colorScheme.surfaceVariant,
                    onRatingUpdate: (rating) {
                      setState(() => _rating = rating);
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _rating == 0
                        ? 'No rating'
                        : '${_rating.toStringAsFixed(1)} / 5.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Notes'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Personal notes',
                hintText: 'Your thoughts, tips, or anything you want to remember...',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Icon(Icons.notes),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formatHours(double hours) {
    if (hours == 0) return '0h';
    if (hours < 1) return '${(hours * 60).round()}m';
    if (hours == hours.truncate()) return '${hours.truncate()}h';
    return '${hours.toStringAsFixed(1)}h';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  final GameStatus selected;
  final ValueChanged<GameStatus> onChanged;

  const _StatusSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: GameStatus.values.map((status) {
        final isSelected = status == selected;
        return GestureDetector(
          onTap: () => onChanged(status),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? status.color.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? status.color
                    : Theme.of(context).colorScheme.outline.withOpacity(0.4),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  status.icon,
                  size: 18,
                  color: isSelected
                      ? status.color
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  status.label,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? status.color
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SliderField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                displayValue,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
