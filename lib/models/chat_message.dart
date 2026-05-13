enum MessageType { text, image, audio }

class ChatMessage {
  final bool isUser;
  final MessageType type;
  final String? text; // For text content (user or assistant)
  final String? filePath; // For image or audio file path
  final DateTime time;

  ChatMessage({
    required this.isUser,
    required this.type,
    this.text,
    this.filePath,
    required this.time,
  });
}
