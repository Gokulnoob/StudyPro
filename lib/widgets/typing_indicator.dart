import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  final List<String> userNames;

  const TypingIndicator({
    super.key,
    required this.userNames,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userNames.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey,
            child: Text(
              widget.userNames.first.substring(0, 1).toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getTypingText(),
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDot(0),
                  const SizedBox(width: 4),
                  _buildDot(1),
                  const SizedBox(width: 4),
                  _buildDot(2),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final delay = index * 0.2;
    final animValue = (_animation.value - delay).clamp(0.0, 1.0);
    final opacity = (animValue * 2).clamp(0.0, 1.0);

    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  String _getTypingText() {
    if (widget.userNames.length == 1) {
      return '${widget.userNames.first} is typing...';
    } else if (widget.userNames.length == 2) {
      return '${widget.userNames.first} and ${widget.userNames.last} are typing...';
    } else {
      return '${widget.userNames.first} and ${widget.userNames.length - 1} others are typing...';
    }
  }
}
