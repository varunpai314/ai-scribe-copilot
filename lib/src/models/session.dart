class Session {
  final String id;
  final String doctorId;
  final String patientId;
  final String? templateId;
  final String? sessionTitle;
  final String? sessionSummary;
  final String? transcriptStatus;
  final String? transcript;
  final String? status;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? duration;

  const Session({
    required this.id,
    required this.doctorId,
    required this.patientId,
    this.templateId,
    this.sessionTitle,
    this.sessionSummary,
    this.transcriptStatus,
    this.transcript,
    this.status,
    this.date,
    this.startTime,
    this.endTime,
    this.duration,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      doctorId: json['doctor_id'] as String,
      patientId: json['patient_id'] as String,
      templateId: json['template_id'] as String?,
      sessionTitle: json['session_title'] as String?,
      sessionSummary: json['session_summary'] as String?,
      transcriptStatus: json['transcript_status'] as String?,
      transcript: json['transcript'] as String?,
      status: json['status'] as String?,
      date: json['date'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      duration: json['duration'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'patient_id': patientId,
      'template_id': templateId,
      'session_title': sessionTitle,
      'session_summary': sessionSummary,
      'transcript_status': transcriptStatus,
      'transcript': transcript,
      'status': status,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'duration': duration,
    };
  }

  Session copyWith({
    String? id,
    String? doctorId,
    String? patientId,
    String? templateId,
    String? sessionTitle,
    String? sessionSummary,
    String? transcriptStatus,
    String? transcript,
    String? status,
    String? date,
    String? startTime,
    String? endTime,
    String? duration,
  }) {
    return Session(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      templateId: templateId ?? this.templateId,
      sessionTitle: sessionTitle ?? this.sessionTitle,
      sessionSummary: sessionSummary ?? this.sessionSummary,
      transcriptStatus: transcriptStatus ?? this.transcriptStatus,
      transcript: transcript ?? this.transcript,
      status: status ?? this.status,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
    );
  }
}

class SessionCreateRequest {
  final String doctorId;
  final String patientId;
  final String? templateId;
  final String? sessionTitle;
  final String? status;
  final String? date;
  final String? startTime;

  const SessionCreateRequest({
    required this.doctorId,
    required this.patientId,
    this.templateId,
    this.sessionTitle,
    this.status,
    this.date,
    this.startTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'patient_id': patientId,
      'template_id': templateId,
      'session_title': sessionTitle,
      'status': status,
      'date': date,
      'start_time': startTime,
    };
  }
}

class SessionUpdateRequest {
  final String? sessionTitle;
  final String? sessionSummary;
  final String? transcriptStatus;
  final String? transcript;
  final String? status;
  final String? startTime;
  final String? endTime;
  final String? duration;

  const SessionUpdateRequest({
    this.sessionTitle,
    this.sessionSummary,
    this.transcriptStatus,
    this.transcript,
    this.status,
    this.startTime,
    this.endTime,
    this.duration,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (sessionTitle != null) data['session_title'] = sessionTitle;
    if (sessionSummary != null) data['session_summary'] = sessionSummary;
    if (transcriptStatus != null) data['transcript_status'] = transcriptStatus;
    if (transcript != null) data['transcript'] = transcript;
    if (status != null) data['status'] = status;
    if (startTime != null) data['start_time'] = startTime;
    if (endTime != null) data['end_time'] = endTime;
    if (duration != null) data['duration'] = duration;
    return data;
  }
}

// Session status constants
class SessionStatus {
  static const String active = 'active';
  static const String paused = 'paused';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
}

// Transcript status constants
class TranscriptStatus {
  static const String pending = 'pending';
  static const String processing = 'processing';
  static const String completed = 'completed';
  static const String failed = 'failed';
}
