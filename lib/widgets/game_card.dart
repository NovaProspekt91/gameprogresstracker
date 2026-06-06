import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/game.dart';
import '../models/game_status.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = game.status.color;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  game.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (game.platform.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    game.platform,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusChip(status: game.status),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _InfoBadge(
                            icon: Icons.timer_outlined,
                            label: _formatHours(game.hoursPlayed),
                          ),
                          const SizedBox(width: 12),
                          _InfoBadge(
                            icon: Icons.percent,
                            label: '${game.completionPercent}%',
                          ),
                          const Spacer(),
                          if (game.rating > 0)
                            RatingBarIndicator(
                              rating: game.rating,
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Color(0xFFFFD700),
                              ),
                              itemCount: 5,
                              itemSize: 16,
                            ),
                        ],
                      ),
                      if (game.completionPercent > 0) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: game.completionPercent / 100,
                            backgroundColor: theme.colorScheme.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
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

class _StatusChip extends StatelessWidget {
  final GameStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
