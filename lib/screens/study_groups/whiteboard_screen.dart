import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/study_group.dart';
import '../../models/chat_models.dart';
import '../../services/realtime_communication_service.dart';

class WhiteboardScreen extends StatefulWidget {
  final StudyGroup studyGroup;

  const WhiteboardScreen({
    super.key,
    required this.studyGroup,
  });

  @override
  State<WhiteboardScreen> createState() => _WhiteboardScreenState();
}

class _WhiteboardScreenState extends State<WhiteboardScreen> {
  final List<WhiteboardStroke> _strokes = [];
  final List<WhiteboardPoint> _currentStroke = [];

  StreamSubscription? _whiteboardSubscription;

  Color _selectedColor = Colors.black;
  double _strokeWidth = 3.0;
  bool _isErasing = false;

  @override
  void initState() {
    super.initState();
    _initializeWhiteboard();
  }

  void _initializeWhiteboard() {
    // Subscribe to whiteboard strokes from other users
    _whiteboardSubscription =
        RealTimeCommunicationService.instance.whiteboardStream.listen(
      (stroke) {
        setState(() {
          _strokes.add(stroke);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.studyGroup.name} - Whiteboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearBoard,
            tooltip: 'Clear Board',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveBoard,
            tooltip: 'Save Board',
          ),
        ],
      ),
      body: Column(
        children: [
          // Toolbar
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Color picker
                GestureDetector(
                  onTap: _showColorPicker,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Stroke width slider
                const Text('Width:'),
                Expanded(
                  child: Slider(
                    value: _strokeWidth,
                    min: 1.0,
                    max: 10.0,
                    divisions: 9,
                    onChanged: (value) {
                      setState(() {
                        _strokeWidth = value;
                      });
                    },
                  ),
                ),

                Text(_strokeWidth.toInt().toString()),

                const SizedBox(width: 16),

                // Eraser toggle
                IconButton(
                  icon: Icon(
                    Icons.auto_fix_high,
                    color: _isErasing ? Colors.red : null,
                  ),
                  onPressed: () {
                    setState(() {
                      _isErasing = !_isErasing;
                    });
                  },
                  tooltip: 'Eraser',
                ),

                // Undo button
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: _undo,
                  tooltip: 'Undo',
                ),
              ],
            ),
          ),

          // Whiteboard canvas
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: CustomPaint(
                  painter: WhiteboardPainter(
                    strokes: _strokes,
                    currentStroke: _currentStroke,
                    currentColor: _selectedColor,
                    currentStrokeWidth: _strokeWidth,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _currentStroke.clear();
      _currentStroke.add(WhiteboardPoint(
        x: details.localPosition.dx,
        y: details.localPosition.dy,
      ));
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentStroke.add(WhiteboardPoint(
        x: details.localPosition.dx,
        y: details.localPosition.dy,
      ));
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentStroke.isNotEmpty) {
      final stroke = WhiteboardStroke(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        points: List.from(_currentStroke),
        color: _isErasing ? '#FFFFFF' : _colorToHex(_selectedColor),
        strokeWidth: _isErasing ? _strokeWidth * 2 : _strokeWidth,
        userId: 'current_user_id',
        timestamp: DateTime.now(),
      );

      setState(() {
        _strokes.add(stroke);
        _currentStroke.clear();
      });

      // Send stroke to other users
      RealTimeCommunicationService.instance.sendWhiteboardStroke(stroke);
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Colors.black,
            Colors.red,
            Colors.blue,
            Colors.green,
            Colors.yellow,
            Colors.orange,
            Colors.purple,
            Colors.pink,
          ].map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                  _isErasing = false;
                });
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _selectedColor == color
                        ? Colors.grey
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _undo() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _strokes.removeLast();
      });
    }
  }

  void _clearBoard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Board'),
        content: const Text(
            'Are you sure you want to clear the entire whiteboard? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _strokes.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _saveBoard() {
    // Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Whiteboard saved!')),
    );
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  void dispose() {
    _whiteboardSubscription?.cancel();
    super.dispose();
  }
}

class WhiteboardPainter extends CustomPainter {
  final List<WhiteboardStroke> strokes;
  final List<WhiteboardPoint> currentStroke;
  final Color currentColor;
  final double currentStrokeWidth;

  WhiteboardPainter({
    required this.strokes,
    required this.currentStroke,
    required this.currentColor,
    required this.currentStrokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw completed strokes
    for (final stroke in strokes) {
      if (stroke.points.length > 1) {
        final paint = Paint()
          ..color = _hexToColor(stroke.color)
          ..strokeWidth = stroke.strokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        final path = Path();
        path.moveTo(stroke.points.first.x, stroke.points.first.y);

        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].x, stroke.points[i].y);
        }

        canvas.drawPath(path, paint);
      }
    }

    // Draw current stroke being drawn
    if (currentStroke.length > 1) {
      final paint = Paint()
        ..color = currentColor
        ..strokeWidth = currentStrokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(currentStroke.first.x, currentStroke.first.y);

      for (int i = 1; i < currentStroke.length; i++) {
        path.lineTo(currentStroke[i].x, currentStroke[i].y);
      }

      canvas.drawPath(path, paint);
    }
  }

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.black;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
