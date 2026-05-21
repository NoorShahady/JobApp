class Message {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  bool read;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.read = false,
  });

  Map<String, dynamic> toJson() => {
    'senderId': senderId,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'read': read,
  };

  factory Message.fromJson(Map<String, dynamic> json, String docId) => Message(
    id: docId,
    senderId: json['senderId'] ?? '',
    text: json['text'] ?? '',
    timestamp: json['timestamp'] != null
        ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
        : DateTime.now(),
    read: json['read'] ?? false,
  );
}
