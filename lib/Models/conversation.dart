class Conversation {
  final String id;
  final List<String> participantIds;
  final String lastMessage;
  final String lastMessageSenderId;
  final DateTime lastMessageTime;

  Conversation({
    required this.id,
    required this.participantIds,
    this.lastMessage = '',
    this.lastMessageSenderId = '',
    DateTime? lastMessageTime,
  }) : lastMessageTime = lastMessageTime ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'participantIds': participantIds,
    'lastMessage': lastMessage,
    'lastMessageSenderId': lastMessageSenderId,
    'lastMessageTime': lastMessageTime.toIso8601String(),
  };

  factory Conversation.fromJson(Map<String, dynamic> json, String docId) =>
      Conversation(
        id: docId,
        participantIds: List<String>.from(json['participantIds'] ?? []),
        lastMessage: json['lastMessage'] ?? '',
        lastMessageSenderId: json['lastMessageSenderId'] ?? '',
        lastMessageTime: json['lastMessageTime'] != null
            ? DateTime.tryParse(json['lastMessageTime']) ?? DateTime.now()
            : DateTime.now(),
      );
}
