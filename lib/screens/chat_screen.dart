import 'package:flutter/material.dart';
import '../models/family_user.dart';
import '../models/family_group.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';
import '../widgets/connection_status.dart';

class ChatScreen extends StatefulWidget {
  final FamilyGroup group;
  final FamilyUser currentUser;

  const ChatScreen({
    super.key,
    required this.group,
    required this.currentUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    try {
      final chatService = ChatService();
      chatService.getMessagesStream(widget.group.id).listen((msgs) {
        if (mounted) setState(() => _messages = msgs);
      });
    } catch (e) {
      _loadFromMemory();
    }
  }

  void _loadFromMemory() {
    _messages = [
      Message(id: 'msg_001', familyId: widget.group.familyId, senderId: 'user_002', senderName: 'Jane', groupId: widget.group.id, type: MessageType.text, content: 'Hey family! 🏠 Anyone home yet?', createdAt: DateTime.now().subtract(const Duration(minutes: 30))),
      Message(id: 'msg_002', familyId: widget.group.familyId, senderId: 'user_001', senderName: 'John', groupId: widget.group.id, type: MessageType.text, content: 'Just got home! Traffic was terrible 😤', createdAt: DateTime.now().subtract(const Duration(minutes: 25))),
      Message(id: 'msg_003', familyId: widget.group.familyId, senderId: 'user_005', senderName: 'Mary', groupId: widget.group.id, type: MessageType.text, content: 'Emma finished her homework! 🎉 So proud of her', createdAt: DateTime.now().subtract(const Duration(minutes: 20))),
      Message(id: 'msg_004', familyId: widget.group.familyId, senderId: 'user_003', senderName: 'Emma', groupId: widget.group.id, type: MessageType.text, content: 'Can we have pizza tonight? 🍕', createdAt: DateTime.now().subtract(const Duration(minutes: 15))),
      Message(id: 'msg_005', familyId: widget.group.familyId, senderId: 'user_002', senderName: 'Jane', groupId: widget.group.id, type: MessageType.text, content: 'lol sure! 👍', createdAt: DateTime.now().subtract(const Duration(minutes: 10))),
      Message(id: 'msg_006', familyId: widget.group.familyId, senderId: 'user_001', senderName: 'John', groupId: widget.group.id, type: MessageType.text, content: 'Perfect! I\'ll be there in 10 min', createdAt: DateTime.now().subtract(const Duration(minutes: 5))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: ConnectionStatusIndicator(showDetails: false),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('No messages yet'))
                : ListView.builder(
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (ctx, i) => _buildMessageTile(_messages[_messages.length - 1 - i]),
                  ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageTile(Message msg) {
    final isMe = msg.senderId == widget.currentUser.id;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.content,
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(msg.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            color: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      final chatService = ChatService();
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        familyId: widget.group.familyId,
        groupId: widget.group.id,
        senderId: widget.currentUser.id,
        senderName: widget.currentUser.firstName,
        type: MessageType.text,
        content: text,
        createdAt: DateTime.now(),
      );
      chatService.sendMessage(message);
      _messageController.clear();
    } catch (e) {}
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}