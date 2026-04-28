import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:umuragizi/utils/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  // ✅ FIX 1 — ScrollController déclaré
  final ScrollController _scrollController = ScrollController();

  bool _isRecording = false;
  final AudioRecorder _audioRecorder = AudioRecorder();

  // ✅ FIX 2 — Message initial avec le champ "type"
  final List<Map<String, dynamic>> _messages = [
    {
      "type": "text",
      "text": "Bonjour ! Comment puis-je vous aider aujourd'hui ?",
      "isMe": false,
      "time": null,
    },
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null) {
      setState(() {
        _messages.add({
          "type": "image",
          "path": image.path,
          "isMe": true,
          "time": DateTime.now(),
        });
      });
      _scrollToBottom();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final String path =
            '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        if (!_isRecording) {
          await _audioRecorder.start(const RecordConfig(), path: path);
          setState(() => _isRecording = true);
        } else {
          final pathResult = await _audioRecorder.stop();
          setState(() => _isRecording = false);

          if (pathResult != null) {
            setState(() {
              _messages.add({
                "type": "audio",
                "path": pathResult,
                "isMe": true,
                "time": DateTime.now(),
              });
            });
            _scrollToBottom();
          }
        }
      }
    } catch (e) {
      debugPrint("Erreur enregistrement: $e");
    }
  }

  void _handleSend() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        "type": "text",
        "text": text,
        "isMe": true,
        "time": DateTime.now(),
      });
      _messageController.clear();
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColorOf(context),
      appBar: _buildCustomAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              // ✅ FIX 3 — ScrollController branché
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // ✅ FIX 4 — On passe tout le message, pas seulement le texte
                return _buildChatBubble(_messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.cardBackgroundOf(context),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withValues(alpha: 0.1),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.auto_awesome,
                color: AppTheme.primaryPurple, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Assistant Umuragizi",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryOf(context)),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text("En ligne",
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ FIX 5 — Gère text, image et audio
  Widget _buildChatBubble(Map<String, dynamic> msg) {
    final bool isMe = msg["isMe"] as bool;
    final String type = msg["type"] as String? ?? "text";

    Widget content;

    switch (type) {
      case "image":
        content = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(msg["path"] as String),
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        );
        break;

      case "audio":
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_fill,
                color: isMe ? Colors.white : AppTheme.primaryPurple, size: 28),
            const SizedBox(width: 8),
            Text(
              "Message vocal",
              style: TextStyle(
                color: isMe ? Colors.white : AppTheme.textPrimaryOf(context),
                fontSize: 14,
              ),
            ),
          ],
        );
        break;

      default: // "text"
        content = Text(
          msg["text"] as String? ?? "",
          style: TextStyle(
            color: isMe ? Colors.white : AppTheme.textPrimaryOf(context),
            fontSize: 14,
          ),
        );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryPurple : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(10),
            topRight: const Radius.circular(10),
            bottomLeft: Radius.circular(isMe ? 10 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: content,
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundOf(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildIconButton(
              icon: Icons.image_outlined,
              onPressed: _pickImage,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColorOf(context),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: 5,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: "Écrivez votre message...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 12),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (text) => setState(() {}),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _messageController.text.isEmpty
                ? _buildIconButton(
                    icon: _isRecording
                        ? Icons.stop_circle_outlined
                        : Icons.mic_none_rounded,
                    onPressed: _startRecording,
                    isCircular: true,
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon:
                          const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _handleSend,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isCircular = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.1),
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular ? null : BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppTheme.primaryPurple, size: 22),
        onPressed: onPressed,
      ),
    );
  }
}
