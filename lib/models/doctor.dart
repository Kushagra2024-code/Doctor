/// Represents an AI doctor specialization
class Doctor {
  final String id;
  final String name;
  final String description;
  final String systemPrompt;
  final bool isPremium;
  final String emoji;

  const Doctor({
    required this.id,
    required this.name,
    required this.description,
    required this.systemPrompt,
    required this.isPremium,
    required this.emoji,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'systemPrompt': systemPrompt,
        'isPremium': isPremium,
        'emoji': emoji,
      };

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        systemPrompt: json['systemPrompt'] as String,
        isPremium: json['isPremium'] as bool,
        emoji: json['emoji'] as String,
      );
}
