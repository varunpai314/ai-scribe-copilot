// lib/src/models/template.dart

class Template {
  final String id;
  final String? doctorId;
  final String title;
  final String type; // 'default', 'predefined', 'custom'

  const Template({
    required this.id,
    this.doctorId,
    required this.title,
    required this.type,
  });

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id: json['id'] as String,
      doctorId: json['doctor_id'] as String?,
      title: json['title'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'doctor_id': doctorId, 'title': title, 'type': type};
  }

  Template copyWith({
    String? id,
    String? doctorId,
    String? title,
    String? type,
  }) {
    return Template(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      title: title ?? this.title,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Template && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Template{id: $id, doctorId: $doctorId, title: $title, type: $type}';
  }
}

class TemplateResponse {
  final List<Template> templates;

  const TemplateResponse({required this.templates});

  factory TemplateResponse.fromJson(Map<String, dynamic> json) {
    return TemplateResponse(
      templates: (json['templates'] as List<dynamic>)
          .map((item) => Template.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
