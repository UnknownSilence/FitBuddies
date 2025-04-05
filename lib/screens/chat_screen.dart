import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../services/message_service.dart';
import '../services/user_service.dart';
import '../screens/match_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageService _messageService = MockMessageService();
  final UserService _userService = MockUserService();
  final TextEditingController _messageController = TextEditingController();
  late Future<User> _currentUserFuture;
  late Future<User?> _partnerFuture;
  late Future<List<Message>> _messagesFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentUserFuture = _userService.getCurrentUser();
    _loadData();
  }

  Future<void> _loadData() async {
    final currentUser = await _currentUserFuture;

    if (currentUser.accountabilityPartnerId != null) {
      _partnerFuture = _userService.getPartnerProfile(
        currentUser.accountabilityPartnerId!,
      );
      _messagesFuture = _messageService.getConversation(
        currentUser.id,
        currentUser.accountabilityPartnerId!,
      );
    } else {
      _partnerFuture = Future.value(null);
      _messagesFuture = Future.value([]);
    }
  }

  void _sendMessage(String userId, String partnerId) async {
    if (_messageController.text.isEmpty) return;

    final message = Message(
      id: '', // Will be assigned by service
      senderId: userId,
      receiverId: partnerId,
      content: _messageController.text,
      timestamp: DateTime.now(),
    );

    _messageController.clear();

    await _messageService.sendMessage(message);

    // Refresh messages
    setState(() {
      _messagesFuture = _messageService.getConversation(userId, partnerId);
    });

    // Scroll to bottom after messages update
    _messagesFuture.then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _currentUserFuture,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (userSnapshot.hasError || !userSnapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chat')),
            body: const Center(child: Text('Error loading user data')),
          );
        }

        final currentUser = userSnapshot.data!;

        return FutureBuilder<User?>(
          future: _partnerFuture,
          builder: (context, partnerSnapshot) {
            if (partnerSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final partner = partnerSnapshot.data;

            return Scaffold(
              appBar: AppBar(
                title: Text(partner?.name ?? 'Chat'),
                leading:
                    partner != null
                        ? CircleAvatar(
                          backgroundImage: NetworkImage(
                            partner.profileImageUrl,
                          ),
                          radius: 16,
                        )
                        : null,
              ),
              body:
                  partner == null
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'You don\'t have an accountability partner yet.',
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MatchScreen(),
                                  ),
                                );
                              },
                              child: const Text('Find a Partner'),
                            ),
                          ],
                        ),
                      )
                      : Column(
                        children: [
                          Expanded(
                            child: FutureBuilder<List<Message>>(
                              future: _messagesFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text('Error: ${snapshot.error}'),
                                  );
                                }

                                final messages = snapshot.data!;

                                if (messages.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      'No messages yet. Start the conversation!',
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(16),
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    final message = messages[index];
                                    final isMe =
                                        message.senderId == currentUser.id;

                                    return _buildMessageBubble(message, isMe);
                                  },
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    decoration: const InputDecoration(
                                      hintText: 'Type a message...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(24),
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed:
                                      () => _sendMessage(
                                        currentUser.id,
                                        partner.id,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isMe ? Theme.of(context).colorScheme.primary : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
