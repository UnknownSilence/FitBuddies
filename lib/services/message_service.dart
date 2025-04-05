import '../models/message.dart';

abstract class MessageService {
  Future<List<Message>> getConversation(String user1Id, String user2Id);
  Future<Message> sendMessage(Message message);
  Future<bool> markAsRead(String messageId);
}

class MockMessageService implements MessageService {
  final List<Message> _messages = [
    Message(
      id: 'msg1',
      senderId: 'user1',
      receiverId: 'user2',
      content: 'Hey, how was your workout today?',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
    ),
    Message(
      id: 'msg2',
      senderId: 'user2',
      receiverId: 'user1',
      content:
          'It was great! I managed to increase my weights on all exercises.',
      timestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 45)),
      isRead: true,
    ),
    Message(
      id: 'msg3',
      senderId: 'user1',
      receiverId: 'user2',
      content: 'That\'s awesome! I\'m planning to go tomorrow. Any tips?',
      timestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 30)),
      isRead: true,
    ),
    Message(
      id: 'msg4',
      senderId: 'user2',
      receiverId: 'user1',
      content: 'Make sure to focus on your form. I noticed it really helps!',
      timestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 15)),
      isRead: false,
    ),
  ];

  @override
  Future<List<Message>> getConversation(String user1Id, String user2Id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _messages
        .where(
          (msg) =>
              (msg.senderId == user1Id && msg.receiverId == user2Id) ||
              (msg.senderId == user2Id && msg.receiverId == user1Id),
        )
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  @override
  Future<Message> sendMessage(Message message) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final newMessage = Message(
      id: 'msg${_messages.length + 1}',
      senderId: message.senderId,
      receiverId: message.receiverId,
      content: message.content,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _messages.add(newMessage);
    return newMessage;
  }

  @override
  Future<bool> markAsRead(String messageId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    final messageIndex = _messages.indexWhere((msg) => msg.id == messageId);
    if (messageIndex >= 0) {
      _messages[messageIndex] = _messages[messageIndex].copyWith(isRead: true);
      return true;
    }
    return false;
  }
}
