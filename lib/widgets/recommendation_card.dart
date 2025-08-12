import 'package:flutter/material.dart';
import '../models/career_models.dart';

class RecommendationCard extends StatelessWidget {
  final ActionableRecommendation recommendation;
  final VoidCallback? onTap;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(recommendation.category)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(recommendation.category),
                      color: _getCategoryColor(recommendation.category),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          recommendation.category,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color:
                                    _getCategoryColor(recommendation.category),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(recommendation.priority)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getPriorityText(recommendation.priority),
                      style: TextStyle(
                        color: _getPriorityColor(recommendation.priority),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                recommendation.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (recommendation.actionSteps.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Action Steps:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                ...recommendation.actionSteps.take(3).map((step) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              step,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    )),
                if (recommendation.actionSteps.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${recommendation.actionSteps.length - 3} more steps',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Impact: ${(recommendation.impactScore * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    'Due: ${_formatDate(recommendation.dueDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'skill development':
      case 'skills':
        return const Color(0xFF3B82F6);
      case 'job search':
      case 'search':
        return const Color(0xFF10B981);
      case 'networking':
        return const Color(0xFFF59E0B);
      case 'career change':
      case 'career':
        return const Color(0xFFEF4444);
      case 'interview':
        return const Color(0xFF8B5CF6);
      case 'resume':
        return const Color(0xFF06B6D4);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'skill development':
      case 'skills':
        return Icons.school_outlined;
      case 'job search':
      case 'search':
        return Icons.search_outlined;
      case 'networking':
        return Icons.people_outline;
      case 'career change':
      case 'career':
        return Icons.trending_up_outlined;
      case 'interview':
        return Icons.record_voice_over_outlined;
      case 'resume':
        return Icons.description_outlined;
      default:
        return Icons.lightbulb_outline;
    }
  }

  Color _getPriorityColor(int priority) {
    if (priority >= 8) {
      return const Color(0xFFEF4444); // High priority
    } else if (priority >= 5) {
      return const Color(0xFFF59E0B); // Medium priority
    } else {
      return const Color(0xFF6B7280); // Low priority
    }
  }

  String _getPriorityText(int priority) {
    if (priority >= 8) {
      return 'High';
    } else if (priority >= 5) {
      return 'Medium';
    } else {
      return 'Low';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference < 7) {
      return '${difference}d';
    } else {
      return '${(difference / 7).ceil()}w';
    }
  }
}
