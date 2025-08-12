import 'package:flutter/material.dart';
import 'dart:async';

class SmartStudySession extends StatefulWidget {
  final String? studyGroupId;
  final String subject;

  const SmartStudySession({
    super.key,
    this.studyGroupId,
    required this.subject,
  });

  @override
  State<SmartStudySession> createState() => _SmartStudySessionState();
}

class _SmartStudySessionState extends State<SmartStudySession> {
  Timer? _timer;
  Duration _remainingTime = const Duration(minutes: 25); // Pomodoro default
  bool _isRunning = false;
  bool _isBreak = false;
  int _completedSessions = 0;
  int _focusScore = 100;
  List<FocusEvent> _focusEvents = [];

  // Customizable session settings
  Duration _workDuration = const Duration(minutes: 25);
  Duration _shortBreakDuration = const Duration(minutes: 5);
  Duration _longBreakDuration = const Duration(minutes: 15);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Study Session - ${widget.subject}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isBreak
                ? [Colors.green.shade300, Colors.green.shade600]
                : [Colors.blue.shade300, Colors.blue.shade600],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildSessionInfo(),
                const SizedBox(height: 40),
                _buildTimer(),
                const SizedBox(height: 40),
                _buildControls(),
                const SizedBox(height: 40),
                _buildFocusTracker(),
                const Spacer(),
                _buildSessionStats(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem(
              'Sessions',
              '$_completedSessions',
              Icons.check_circle,
              Colors.green,
            ),
            _buildInfoItem(
              'Focus Score',
              '$_focusScore%',
              Icons.psychology,
              Colors.purple,
            ),
            _buildInfoItem(
              'Mode',
              _isBreak ? 'Break' : 'Study',
              _isBreak ? Icons.coffee : Icons.book,
              _isBreak ? Colors.orange : Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTimer() {
    final progress = 1.0 -
        (_remainingTime.inSeconds /
            (_isBreak
                ? _shortBreakDuration.inSeconds
                : _workDuration.inSeconds));

    return Column(
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 12,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isBreak ? Colors.green : Colors.blue,
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(_remainingTime),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _isBreak ? 'Break Time' : 'Focus Time',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _isRunning ? _pauseSession : _startSession,
          icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
          label: Text(_isRunning ? 'Pause' : 'Start'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: _isBreak ? Colors.green : Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _resetSession,
          icon: const Icon(Icons.stop),
          label: const Text('Reset'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.9),
            foregroundColor: Colors.grey[700],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _skipSession,
          icon: const Icon(Icons.skip_next),
          label: const Text('Skip'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.9),
            foregroundColor: Colors.grey[700],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildFocusTracker() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Focus Tracking',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFocusButton('Focused', Icons.psychology, Colors.green),
                _buildFocusButton(
                    'Distracted', Icons.phone_android, Colors.orange),
                _buildFocusButton('Break', Icons.coffee, Colors.blue),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to log your current state for better insights',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusButton(String label, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () => _logFocusEvent(label),
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildSessionStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Session Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _completedSessions / 4, // 4 sessions for long break
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_completedSessions}/4 sessions until long break',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startSession() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        } else {
          _sessionComplete();
        }
      });
    });
  }

  void _pauseSession() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
  }

  void _resetSession() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingTime = _isBreak ? _shortBreakDuration : _workDuration;
    });
  }

  void _skipSession() {
    _timer?.cancel();
    _sessionComplete();
  }

  void _sessionComplete() {
    _timer?.cancel();

    setState(() {
      _isRunning = false;

      if (!_isBreak) {
        _completedSessions++;
        // Determine break type
        if (_completedSessions % 4 == 0) {
          // Long break after 4 sessions
          _remainingTime = _longBreakDuration;
        } else {
          // Short break
          _remainingTime = _shortBreakDuration;
        }
        _isBreak = true;
      } else {
        // End of break, start new work session
        _remainingTime = _workDuration;
        _isBreak = false;
      }
    });

    // Show completion notification
    _showSessionCompleteDialog();
  }

  void _showSessionCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isBreak ? 'Work Session Complete!' : 'Break Complete!'),
        content: Text(
          _isBreak
              ? 'Great job! Time for a well-deserved break.'
              : 'Break\'s over! Ready to get back to studying?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startSession();
            },
            child: Text(_isBreak ? 'Start Break' : 'Continue Studying'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
        ],
      ),
    );
  }

  void _logFocusEvent(String eventType) {
    _focusEvents.add(FocusEvent(
      type: eventType,
      timestamp: DateTime.now(),
    ));

    // Update focus score based on event
    setState(() {
      switch (eventType) {
        case 'Focused':
          _focusScore = (_focusScore + 5).clamp(0, 100);
          break;
        case 'Distracted':
          _focusScore = (_focusScore - 10).clamp(0, 100);
          break;
      }
    });
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDurationSetting('Work Duration', _workDuration, (duration) {
              setState(() {
                _workDuration = duration;
                if (!_isBreak) _remainingTime = duration;
              });
            }),
            _buildDurationSetting('Short Break', _shortBreakDuration,
                (duration) {
              setState(() => _shortBreakDuration = duration);
            }),
            _buildDurationSetting('Long Break', _longBreakDuration, (duration) {
              setState(() => _longBreakDuration = duration);
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSetting(
      String label, Duration duration, Function(Duration) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        DropdownButton<int>(
          value: duration.inMinutes,
          items: [5, 10, 15, 20, 25, 30, 45, 60]
              .map((minutes) => DropdownMenuItem(
                    value: minutes,
                    child: Text('${minutes}m'),
                  ))
              .toList(),
          onChanged: (minutes) {
            if (minutes != null) {
              onChanged(Duration(minutes: minutes));
            }
          },
        ),
      ],
    );
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds % 60)}';
  }
}

class FocusEvent {
  final String type;
  final DateTime timestamp;

  FocusEvent({
    required this.type,
    required this.timestamp,
  });
}
