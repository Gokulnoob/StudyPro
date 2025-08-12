import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/study_group.dart';
import '../../models/chat_models.dart';
import '../../services/realtime_communication_service.dart';

class VoiceCallScreen extends StatefulWidget {
  final StudyGroup studyGroup;
  final bool isVideoCall;

  const VoiceCallScreen({
    super.key,
    required this.studyGroup,
    this.isVideoCall = false,
  });

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  final List<CallParticipant> _participants = [];
  StreamSubscription? _callEventsSubscription;

  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerOn = false;
  Duration _callDuration = Duration.zero;
  Timer? _callTimer;

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  void _initializeCall() {
    // Subscribe to call events
    _callEventsSubscription =
        RealTimeCommunicationService.instance.callEventsStream.listen(
      (event) {
        switch (event['type']) {
          case 'participant_joined':
            _addParticipant(CallParticipant.fromJson(event['participant']));
            break;
          case 'participant_left':
            _removeParticipant(event['userId']);
            break;
          case 'participant_muted':
            _updateParticipantMute(event['userId'], event['isMuted']);
            break;
          case 'participant_video_toggled':
            _updateParticipantVideo(event['userId'], event['isVideoEnabled']);
            break;
        }
      },
    );

    // Add current user as participant
    _addParticipant(CallParticipant(
      userId: 'current_user_id',
      name: 'You',
      joinedAt: DateTime.now(),
      isMuted: _isMuted,
      isVideoEnabled: _isVideoEnabled,
    ));

    // Start call timer
    _startCallTimer();

    // Initialize WebRTC for actual voice/video
    _initializeWebRTC();
  }

  void _initializeWebRTC() {
    // In a real implementation, you would:
    // 1. Initialize WebRTC engine (e.g., Agora, Twilio, etc.)
    // 2. Join the voice/video channel
    // 3. Handle audio/video streams
    // 4. Set up event listeners for participant changes

    // For now, we'll simulate with mock participants
    Future.delayed(const Duration(seconds: 2), () {
      _addParticipant(CallParticipant(
        userId: 'user1',
        name: 'Alice Johnson',
        joinedAt: DateTime.now(),
      ));
    });

    Future.delayed(const Duration(seconds: 5), () {
      _addParticipant(CallParticipant(
        userId: 'user2',
        name: 'Bob Smith',
        joinedAt: DateTime.now(),
      ));
    });
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration = Duration(seconds: _callDuration.inSeconds + 1);
      });
    });
  }

  void _addParticipant(CallParticipant participant) {
    setState(() {
      _participants.removeWhere((p) => p.userId == participant.userId);
      _participants.add(participant);
    });
  }

  void _removeParticipant(String userId) {
    setState(() {
      _participants.removeWhere((p) => p.userId == userId);
    });
  }

  void _updateParticipantMute(String userId, bool isMuted) {
    setState(() {
      final index = _participants.indexWhere((p) => p.userId == userId);
      if (index != -1) {
        _participants[index] = CallParticipant(
          userId: _participants[index].userId,
          name: _participants[index].name,
          isMuted: isMuted,
          isVideoEnabled: _participants[index].isVideoEnabled,
          joinedAt: _participants[index].joinedAt,
          leftAt: _participants[index].leftAt,
        );
      }
    });
  }

  void _updateParticipantVideo(String userId, bool isVideoEnabled) {
    setState(() {
      final index = _participants.indexWhere((p) => p.userId == userId);
      if (index != -1) {
        _participants[index] = CallParticipant(
          userId: _participants[index].userId,
          name: _participants[index].name,
          isMuted: _participants[index].isMuted,
          isVideoEnabled: isVideoEnabled,
          joinedAt: _participants[index].joinedAt,
          leftAt: _participants[index].leftAt,
        );
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _updateParticipantMute('current_user_id', _isMuted);
    // In real implementation: WebRTCService.instance.toggleMute();
  }

  void _toggleVideo() {
    if (!widget.isVideoCall) return;

    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
    _updateParticipantVideo('current_user_id', _isVideoEnabled);
    // In real implementation: WebRTCService.instance.toggleVideo();
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    // In real implementation: Handle speaker toggle
  }

  void _endCall() {
    _callTimer?.cancel();
    // In real implementation: WebRTCService.instance.leaveCall();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    widget.studyGroup.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDuration(_callDuration),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Participants grid
            Expanded(
              child: widget.isVideoCall
                  ? _buildVideoGrid()
                  : _buildAudioParticipants(),
            ),

            // Control buttons
            Container(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute button
                  FloatingActionButton(
                    onPressed: _toggleMute,
                    backgroundColor:
                        _isMuted ? Colors.red : Colors.white.withOpacity(0.2),
                    child: Icon(
                      _isMuted ? Icons.mic_off : Icons.mic,
                      color: _isMuted ? Colors.white : Colors.white,
                    ),
                  ),

                  // Speaker button (voice call only)
                  if (!widget.isVideoCall)
                    FloatingActionButton(
                      onPressed: _toggleSpeaker,
                      backgroundColor: _isSpeakerOn
                          ? Colors.blue
                          : Colors.white.withOpacity(0.2),
                      child: Icon(
                        _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                        color: Colors.white,
                      ),
                    ),

                  // Video button (video call only)
                  if (widget.isVideoCall)
                    FloatingActionButton(
                      onPressed: _toggleVideo,
                      backgroundColor: _isVideoEnabled
                          ? Colors.white.withOpacity(0.2)
                          : Colors.red,
                      child: Icon(
                        _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                        color: Colors.white,
                      ),
                    ),

                  // End call button
                  FloatingActionButton(
                    onPressed: _endCall,
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.call_end, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _participants.length <= 2 ? 1 : 2,
        childAspectRatio: 16 / 9,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _participants.length,
      itemBuilder: (context, index) {
        final participant = _participants[index];
        return _buildVideoTile(participant);
      },
    );
  }

  Widget _buildVideoTile(CallParticipant participant) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Video placeholder (in real app, this would be the video stream)
          if (participant.isVideoEnabled)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.blue[300]!, Colors.purple[300]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(Icons.person, size: 64, color: Colors.white),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[700],
              ),
              child: const Center(
                child:
                    Icon(Icons.videocam_off, size: 64, color: Colors.white54),
              ),
            ),

          // Participant info
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      participant.name,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (participant.isMuted)
                    const Icon(Icons.mic_off, color: Colors.red, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioParticipants() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Speaking indicator
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.group,
              size: 80,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 32),

          // Participants list
          ...(_participants
              .map((participant) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          participant.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        if (participant.isMuted)
                          const Icon(Icons.mic_off, color: Colors.red, size: 16)
                        else
                          const Icon(Icons.mic, color: Colors.green, size: 16),
                      ],
                    ),
                  ))
              .toList()),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _callEventsSubscription?.cancel();
    super.dispose();
  }
}
