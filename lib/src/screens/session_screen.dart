import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/session.dart';
import '../models/doctor.dart';
import '../services/session_service.dart';
import '../services/auth_service.dart';

class SessionScreen extends StatefulWidget {
  final String patientId;
  final String? sessionId;
  final String? templateId;
  final String? preDefinedSessionTitle;

  const SessionScreen({
    super.key,
    required this.patientId,
    this.sessionId,
    this.templateId,
    this.preDefinedSessionTitle,
  });

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  Session? _currentSession;
  Doctor? _currentDoctor;
  bool _isLoading = true;
  bool _isRecording = false;
  bool _isPaused = false;
  String _transcript = '';
  Duration _sessionDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get current doctor
      _currentDoctor = await AuthService.getCurrentDoctor();

      if (_currentDoctor == null) {
        _showError('Authentication required');
        return;
      }

      // If sessionId is provided, load existing session
      if (widget.sessionId != null) {
        _currentSession = await SessionService.getSession(widget.sessionId!);
        _transcript = _currentSession?.transcript ?? '';

        // Calculate session duration if session is active
        if (_currentSession?.startTime != null &&
            _currentSession?.status == SessionStatus.active) {
          final startTime = DateTime.parse(_currentSession!.startTime!);
          _sessionDuration = DateTime.now().difference(startTime);
          _isRecording = true;
        } else if (_currentSession?.status == SessionStatus.paused) {
          _isPaused = true;
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to initialize session: $e');
    }
  }

  Future<void> _startNewSession() async {
    try {
      if (_currentDoctor == null) {
        _showError('Authentication required');
        return;
      }

      // Use pre-defined session title and template if available
      final sessionTitle =
          widget.preDefinedSessionTitle ??
          'Session ${DateTime.now().toString().substring(0, 16)}';

      String sessionId;
      if (widget.templateId != null) {
        // Use the specific method for creating session with template
        sessionId = await SessionService.createSessionWithTemplate(
          doctorId: _currentDoctor!.id,
          patientId: widget.patientId,
          templateId: widget.templateId!,
          sessionTitle: sessionTitle,
        );
      } else {
        // Fallback to original method
        final request = SessionCreateRequest(
          doctorId: _currentDoctor!.id,
          patientId: widget.patientId,
          sessionTitle: sessionTitle,
          status: SessionStatus.active,
          date: DateTime.now().toIso8601String().substring(0, 10),
          startTime: DateTime.now().toIso8601String(),
        );
        sessionId = await SessionService.createSession(request);
      }

      // Create a session object from the returned ID
      final session = Session(
        id: sessionId,
        doctorId: _currentDoctor!.id,
        patientId: widget.patientId,
        templateId: widget.templateId,
        sessionTitle: sessionTitle,
        status: SessionStatus.active,
        date: DateTime.now().toIso8601String().substring(0, 10),
        startTime: DateTime.now().toIso8601String(),
      );

      setState(() {
        _currentSession = session;
        _isRecording = true;
        _isPaused = false;
        _sessionDuration = Duration.zero;
      });

      _startDurationTimer();
      _showSuccess('Session started successfully');
    } catch (e) {
      _showError('Failed to start session: $e');
    }
  }

  Future<void> _pauseSession() async {
    if (_currentSession == null) return;

    try {
      final updatedSession = await SessionService.pauseSession(
        _currentSession!.id,
      );
      setState(() {
        _currentSession = updatedSession;
        _isRecording = false;
        _isPaused = true;
      });

      _showSuccess('Session paused');
    } catch (e) {
      _showError('Failed to pause session: $e');
    }
  }

  Future<void> _resumeSession() async {
    if (_currentSession == null) return;

    try {
      final updatedSession = await SessionService.resumeSession(
        _currentSession!.id,
      );
      setState(() {
        _currentSession = updatedSession;
        _isRecording = true;
        _isPaused = false;
      });

      _startDurationTimer();
      _showSuccess('Session resumed');
    } catch (e) {
      _showError('Failed to resume session: $e');
    }
  }

  Future<void> _endSession() async {
    if (_currentSession == null) return;

    try {
      final updatedSession = await SessionService.endSession(
        _currentSession!.id,
      );
      setState(() {
        _currentSession = updatedSession;
        _isRecording = false;
        _isPaused = false;
      });

      _showSuccess('Session completed successfully');

      // Navigate back or to session summary
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      _showError('Failed to end session: $e');
    }
  }

  void _startDurationTimer() {
    // This would typically be handled by a timer
    // For now, we'll update the duration manually
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading Session...'),
          backgroundColor: Colors.blueGrey.shade700,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentSession?.sessionTitle ?? 'New Session'),
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (_currentSession != null)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // TODO: Show session settings
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Session Status Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getStatusColor(), width: 2),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStatusText(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Duration',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDuration(_sessionDuration),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_currentSession?.date != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _currentSession!.date!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Recording Controls
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Recording Controls',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_currentSession == null)
                      _buildControlButton(
                        icon: Icons.play_arrow,
                        label: 'Start',
                        color: Colors.green,
                        onPressed: _startNewSession,
                      ),
                    if (_currentSession != null && _isRecording)
                      _buildControlButton(
                        icon: Icons.pause,
                        label: 'Pause',
                        color: Colors.orange,
                        onPressed: _pauseSession,
                      ),
                    if (_currentSession != null && _isPaused)
                      _buildControlButton(
                        icon: Icons.play_arrow,
                        label: 'Resume',
                        color: Colors.green,
                        onPressed: _resumeSession,
                      ),
                    if (_currentSession != null)
                      _buildControlButton(
                        icon: Icons.stop,
                        label: 'End',
                        color: Colors.red,
                        onPressed: _endSession,
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Transcript Section
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Live Transcript',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isRecording)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _transcript.isEmpty
                              ? (_isRecording
                                    ? 'Listening for speech...'
                                    : 'Transcript will appear here when recording starts.')
                              : _transcript,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: _transcript.isEmpty
                                ? Colors.grey.shade500
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 30),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    if (_currentSession == null) return Colors.grey;

    switch (_currentSession!.status) {
      case SessionStatus.active:
        return Colors.green;
      case SessionStatus.paused:
        return Colors.orange;
      case SessionStatus.completed:
        return Colors.blue;
      case SessionStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    if (_currentSession == null) return 'Not Started';

    switch (_currentSession!.status) {
      case SessionStatus.active:
        return 'Recording';
      case SessionStatus.paused:
        return 'Paused';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.cancelled:
        return 'Cancelled';
      default:
        return _currentSession!.status ?? 'Unknown';
    }
  }
}
