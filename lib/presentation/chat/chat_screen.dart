import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String roomId;
  const ChatScreen({super.key, required this.roomId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  late RealtimeChannel _channel;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    _channel = Supabase.instance.client.channel(widget.roomId);

    _channel
        .onBroadcast(
          event: 'message',
          callback: (payload) {
            if (mounted) {
              setState(() {
                _messages.add({
                  'text': payload['text'],
                  'isMe': false,
                  'timestamp': DateTime.now(),
                });
              });
            }
          },
        )
        .subscribe((status, error) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            if (mounted) {
              setState(() {
                _isConnected = true;
              });
            }
          }
        });

    // Notify user we are here
    _channel.track({'status': 'online'});
  }

  @override
  void dispose() {
    // Leave the channel when existing
    Supabase.instance.client.removeChannel(_channel);
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();

    // Add to local list
    setState(() {
      _messages.add({'text': text, 'isMe': true, 'timestamp': DateTime.now()});
    });

    // Broadcast to others
    await _channel.sendBroadcastMessage(
      event: 'message',
      payload: {'text': text},
    );
  }

  void _leaveChat() {
    // Unsubscribe happens in dispose, but we can also trigger explicit leave logic here if needed
    context.go('/interests');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat Room',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: _leaveChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      _isConnected ? 'Say hello!' : 'Connecting...',
                      style: const TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    reverse: true, // Start from bottom
                    itemCount: _messages.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      // Reverse index for ListView.builder with reverse: true
                      final messageIndex = _messages.length - 1 - index;
                      final message = _messages[messageIndex];
                      final isMe = message['isMe'] as bool;

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: isMe
                                  ? const Radius.circular(4)
                                  : const Radius.circular(16),
                              bottomRight: isMe
                                  ? const Radius.circular(16)
                                  : const Radius.circular(4),
                            ),
                          ),
                          child: Text(
                            message['text'] as String,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
