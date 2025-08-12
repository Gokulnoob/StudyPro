import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/mood_provider.dart';
import '../../models/mood_entry.dart';
import '../../widgets/optimized_widgets.dart';
import 'add_mood_entry_screen.dart';

class MoodTrackerScreen extends StatelessWidget {
  const MoodTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddMoodEntryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<MoodProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Today's Status
                _buildTodayCard(provider),
                const SizedBox(height: 16),

                // Stats Overview
                _buildStatsCard(provider),
                const SizedBox(height: 16),

                // Recent Entries
                Text(
                  'Recent Entries',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                if (provider.moodEntries.isEmpty)
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mood_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No mood entries yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the + button to log your first mood',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.moodEntries.length,
                    itemBuilder: (context, index) {
                      final entry = provider.moodEntries[index];
                      return MoodEntryCard(entry: entry);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayCard(MoodProvider provider) {
    final todaysEntry = provider.getTodaysMoodEntry();
    final hasEntry = todaysEntry != null;

    return OptimizedCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasEntry ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: hasEntry ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Today\'s Mood',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: hasEntry ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (hasEntry) ...[
              Row(
                children: [
                  Text(
                    MoodLevel.getMoodEmoji(todaysEntry.moodLevel),
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        MoodLevel.getMoodText(todaysEntry.moodLevel),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Logged today',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (todaysEntry.notes != null &&
                  todaysEntry.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  todaysEntry.notes!,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ] else ...[
              Text(
                'You haven\'t logged your mood today yet.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to add mood entry
                },
                icon: const Icon(Icons.add),
                label: const Text('Log Mood'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(MoodProvider provider) {
    return OptimizedCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Statistics',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Streak',
                    '${provider.streakDays} days',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Average',
                    provider.weeklyAverageMoodLevel.toStringAsFixed(1),
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total Entries',
                    '${provider.moodEntries.length}',
                    Icons.calendar_today,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class MoodEntryCard extends StatelessWidget {
  final MoodEntry entry;

  const MoodEntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return OptimizedCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              MoodLevel.getMoodEmoji(entry.moodLevel),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    MoodLevel.getMoodText(entry.moodLevel),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(entry.date),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      entry.notes!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (entry.sleepHours != null)
              Column(
                children: [
                  const Icon(Icons.bedtime, size: 16, color: Colors.grey),
                  Text(
                    '${entry.sleepHours}h',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
