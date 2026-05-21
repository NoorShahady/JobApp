import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Models/message.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String currentUserId;
  final String currentUserName;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String? _conversationId;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _findOrCreateConversation();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _findOrCreateConversation() async {
    try {
      final ids = [widget.currentUserId, widget.otherUserId]..sort();
      final snap = await FirebaseFirestore.instance
          .collection('conversations')
          .where('participantIds', isEqualTo: ids)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        _conversationId = snap.docs.first.id;
      } else {
        final doc = await FirebaseFirestore.instance.collection('conversations').add({
          'participantIds': ids,
          'lastMessage': '',
          'lastMessageSenderId': '',
          'lastMessageTime': DateTime.now().toIso8601String(),
        });
        _conversationId = doc.id;
      }
    } catch (e) {
      if (mounted) setState(() => _error = true);
      return;
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _conversationId == null) return;

    _msgCtrl.clear();

    final msgRef = FirebaseFirestore.instance
        .collection('conversations')
        .doc(_conversationId)
        .collection('messages');

    await msgRef.add({
      'senderId': widget.currentUserId,
      'text': text,
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    });

    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(_conversationId)
        .update({
      'lastMessage': text,
      'lastMessageSenderId': widget.currentUserId,
      'lastMessageTime': DateTime.now().toIso8601String(),
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                      const SizedBox(height: 12),
                      Text('Could not load conversation',
                          style: TextStyle(color: Colors.red[400], fontSize: 16)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(child: _buildMessages()),
                    _buildInputBar(),
                  ],
                ),
    );
  }

  Widget _buildMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('conversations')
          .doc(_conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snap) {
        final msgs = snap.data?.docs ?? [];
        if (msgs.isEmpty) {
          return Center(
            child: Text(
              'No messages yet. Say hello!',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          );
        }
        return ListView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.all(16),
          itemCount: msgs.length,
          itemBuilder: (_, i) {
            final m = Message.fromJson(msgs[i].data() as Map<String, dynamic>, msgs[i].id);
            final isMe = m.senderId == widget.currentUserId;

            if (!isMe && !m.read) {
              FirebaseFirestore.instance
                  .collection('conversations')
                  .doc(_conversationId)
                  .collection('messages')
                  .doc(m.id)
                  .update({'read': true});
            }

            return Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : Colors.grey[100],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
                    bottomRight: isMe ? Radius.zero : const Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isMe ? 0.15 : 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.text,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(m.timestamp),
                          style: TextStyle(
                            color: isMe ? Colors.white70 : Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            m.read ? Icons.done_all : Icons.done,
                            size: 14,
                            color: m.read ? Colors.blue[200] : Colors.white70,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _msgCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue[600],
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.month}/${dt.day}';
  }
}
