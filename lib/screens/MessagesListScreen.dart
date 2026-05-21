import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Models/conversation.dart';
import 'ChatScreen.dart';

class MessagesListScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;

  const MessagesListScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  final _userCache = <String, String>{};

  Future<String> _getUserName(String uid) async {
    if (_userCache.containsKey(uid)) return _userCache[uid]!;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        final name = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
        if (name.isNotEmpty) {
          _userCache[uid] = name;
          return name;
        }
      }
    } catch (_) {}
    _userCache[uid] = uid;
    return uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .where('participantIds', arrayContains: widget.currentUserId)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 12),
                  Text('Could not load conversations',
                      style: TextStyle(color: Colors.red[400], fontSize: 16)),
                ],
              ),
            );
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final convs = snap.data?.docs ?? [];
          if (convs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: TextStyle(color: Colors.grey[400], fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start by applying to a job or messaging an employer',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            );
          }
          final sorted = convs.toList()..sort((a, b) {
            final aTime = (a.data() as Map<String, dynamic>)['lastMessageTime'] ?? '';
            final bTime = (b.data() as Map<String, dynamic>)['lastMessageTime'] ?? '';
            return bTime.toString().compareTo(aTime.toString());
          });
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final data = sorted[i].data() as Map<String, dynamic>;
              final conv = Conversation.fromJson(data, sorted[i].id);
              final otherId = conv.participantIds.firstWhere(
                (id) => id != widget.currentUserId,
                orElse: () => '',
              );
              final isLastFromMe = conv.lastMessageSenderId == widget.currentUserId;

              return FutureBuilder<String>(
                future: _getUserName(otherId),
                builder: (context, nameSnap) {
                  final otherName = nameSnap.data ?? otherId;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                        style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      otherName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      conv.lastMessage.isEmpty
                          ? 'No messages yet'
                          : '${isLastFromMe ? 'You: ' : ''}${conv.lastMessage}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    trailing: Text(
                      _formatTime(conv.lastMessageTime),
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            otherUserId: otherId,
                            otherUserName: otherName,
                            currentUserId: widget.currentUserId,
                            currentUserName: widget.currentUserName,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}';
  }
}
