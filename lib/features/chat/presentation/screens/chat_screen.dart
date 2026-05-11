import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji;

class ChatScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String partnerId;
  const ChatScreen({super.key, required this.roomId, required this.partnerId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late RealtimeChannel _channel;
  bool _isConnected = false;
  bool _isPartnerTyping = false;
  bool _hasPartnerLeft = false;
  Timer? _typingTimer;
  Timer? _connectionBannerTimer;
  String? _partnerUsername;
  bool _showConnectionBanner = false;

  bool _showEmojiPicker = false;
  final FocusNode _focusNode = FocusNode();

  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _typingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _typingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showEmojiPicker = false;
        });
      }
    });

    _initializeChat();
    _fetchPartnerProfile();
  }

  Future<void> _fetchPartnerProfile() async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('username')
          .eq('id', widget.partnerId)
          .single();
      if (mounted) {
        setState(() {
          _partnerUsername = response['username'] as String?;
        });
      }
    } catch (e) {
      debugPrint('Error fetching partner profile: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_isConnected) {
        // Attempt to manually reconnect or just wait for auto-reconnect
        // _channel.subscribe(); // usually auto-reconnects
      }
      // Re-track presence regardless
      final myUserId = Supabase.instance.client.auth.currentUser?.id;
      if (myUserId != null && _isConnected) {
        _channel.track({'user_id': myUserId, 'status': 'online'});
      }
    }
  }

  void _initializeChat() {
    final myUserId = Supabase.instance.client.auth.currentUser?.id;
    _channel = Supabase.instance.client.channel(widget.roomId);

    _channel
        .onBroadcast(
          event: 'message',
          callback: (payload) {
            if (mounted) {
              final messageUserId = payload['userId'];
              // Only add if it's from someone else, to avoid duplication
              // (though we usually add our own immediately)
              if (messageUserId != myUserId) {
                setState(() {
                  _messages.add({
                    'text': payload['text'],
                    'isMe': false,
                    'timestamp': DateTime.now(),
                  });
                  _isPartnerTyping =
                      false; // Stop typing indicator on message receive
                });
                _scrollToBottom();
              }
            }
          },
        )
        .onBroadcast(
          event: 'typing',
          callback: (payload) {
            if (mounted) {
              final isTyping = payload['isTyping'] as bool;
              final userId = payload['userId'];
              if (userId != myUserId) {
                setState(() {
                  _isPartnerTyping = isTyping;
                });
              }
            }
          },
        )
        .onPresenceLeave((payload) {
          // If anyone leaves, we assume it's the partner in a 1-on-1 chat
          // In a more complex app, check payload['user_id'] against partner ID
          if (mounted && payload.leftPresences.isNotEmpty) {
            // Check if the leaver is not us
            final leftUsers = payload.leftPresences
                .map((p) => p.payload['user_id'])
                .toList();
            if (!leftUsers.contains(myUserId)) {
              // Only mark as left if we explicitly know they left the chat,
              // but for now, let's just show a system message instead of locking the chat
              setState(() {
                _hasPartnerLeft = true;
                _messages.add({
                  'text': 'Partner disconnected. You cannot send messages.',
                  'isMe': false,
                  'isSystem': true,
                  'timestamp': DateTime.now(),
                });
              });
            }
          }
        })
        .subscribe((status, error) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            if (mounted) {
              setState(() {
                _isConnected = true;
                _showConnectionBanner = true;
              });
              // Hide banner after 2 seconds
              _connectionBannerTimer?.cancel();
              _connectionBannerTimer = Timer(const Duration(seconds: 2), () {
                if (mounted) {
                  setState(() {
                    _showConnectionBanner = false;
                  });
                }
              });
              // Track our presence so the other user knows we are here
              _channel.track({'user_id': myUserId, 'status': 'online'});
            }
          }
        });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0, // Because we are using reverse: true in ListView
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _channel.unsubscribe();
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    _connectionBannerTimer?.cancel();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _onTyping() {
    final myUserId = Supabase.instance.client.auth.currentUser?.id;
    _channel.sendBroadcastMessage(
      event: 'typing',
      payload: {'isTyping': true, 'userId': myUserId},
    );

    // Debounce the stop typing event
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 1500), () {
      _channel.sendBroadcastMessage(
        event: 'typing',
        payload: {'isTyping': false, 'userId': myUserId},
      );
    });
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || !_isConnected || _hasPartnerLeft) return;

    final myUserId = Supabase.instance.client.auth.currentUser?.id;
    _textController.clear();

    // Add to local list immediately
    setState(() {
      _messages.add({'text': text, 'isMe': true, 'timestamp': DateTime.now()});
    });
    _scrollToBottom();

    // Broadcast to others
    await _channel.sendBroadcastMessage(
      event: 'message',
      payload: {'text': text, 'userId': myUserId},
    );
  }

  void _leaveChat() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Chat'),
        content: const Text('Are you sure you want to exit the chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // 1. Unsubscribe from channel immediately
      _channel.unsubscribe();

      // 2. Ensure both users' searching is stopped in database
      final myUserId = Supabase.instance.client.auth.currentUser?.id;
      if (myUserId != null) {
        try {
          await Supabase.instance.client.rpc(
            'leave_chat',
            params: {
              'leaving_user_id': myUserId,
              'partner_id': widget.partnerId,
            },
          );
        } catch (e) {
          debugPrint('Error clearing searching status: $e');
        }
      }

      if (mounted) {
        context.go('/interests');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reversedMessages = List.of(_messages).reversed.toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          _partnerUsername ?? '',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: _leaveChat,
          ),
        ],
      ),

      body: PopScope(
        canPop: !_showEmojiPicker,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_showEmojiPicker) {
            setState(() => _showEmojiPicker = false);
          }
        },

        child: SafeArea(
          child: Column(
            children: [
              /// CONNECTION BANNER (FIXED)
              AnimatedOpacity(
                opacity: _showConnectionBanner ? 1 : 0,
                duration: const Duration(milliseconds: 400),
                child: AnimatedSlide(
                  offset: _showConnectionBanner
                      ? Offset.zero
                      : const Offset(0, -1),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.green.withValues(alpha: 0.15),
                    child: Center(
                      child: Text(
                        'Securely Connected',
                        style: GoogleFonts.inter(
                          color: Colors.green[400],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /// MESSAGES LIST
              Expanded(
                child: _messages.isEmpty && !_hasPartnerLeft
                    ? Center(
                        child: Text(
                          _isConnected ? 'Say hello!' : 'Connecting...',
                          style: const TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: reversedMessages.length,
                        itemBuilder: (context, index) {
                          final message = reversedMessages[index];
                          final isMe = message['isMe'] ?? false;
                          final isSystem = message['isSystem'] ?? false;

                          /// SYSTEM MESSAGE
                          if (isSystem) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Center(
                                child: Text(
                                  message['text'],
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            );
                          }

                          /// CHAT MESSAGE (FIXED ANIMATION)
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
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
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isMe
                                      ? const Radius.circular(16)
                                      : const Radius.circular(4),
                                  bottomRight: isMe
                                      ? const Radius.circular(4)
                                      : const Radius.circular(16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
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

              /// TYPING INDICATOR (FIXED SIMPLE ANIMATION)
              if (_isPartnerTyping)
                AnimatedOpacity(
                  opacity: 1,
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Partner is typing...',
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ),

              /// INPUT AREA (UNCHANGED LOGIC, CLEANED)
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        enabled: !_hasPartnerLeft && _isConnected,
                        onChanged: (_) => _onTyping(),
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: _hasPartnerLeft
                              ? 'Partner Disconnected'
                              : 'Type a message...',
                          hintStyle: TextStyle(
                            color: _hasPartnerLeft
                                ? Colors.white38
                                : Colors.white54,
                          ),
                          prefixIcon: IconButton(
                            icon: Icon(
                              _showEmojiPicker
                                  ? Icons.keyboard
                                  : Icons.emoji_emotions_outlined,
                              color: Colors.white54,
                            ),
                            onPressed: () {
                              if (_hasPartnerLeft || !_isConnected) return;
                              setState(() {
                                _showEmojiPicker = !_showEmojiPicker;
                                if (_showEmojiPicker) {
                                  _focusNode.unfocus();
                                } else {
                                  _focusNode.requestFocus();
                                }
                              });
                            },
                          ),
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
                      ),
                    ),

                    const SizedBox(width: 8),

                    CircleAvatar(
                      backgroundColor: (_hasPartnerLeft || !_isConnected)
                          ? Colors.grey
                          : Theme.of(context).colorScheme.primary,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: (_hasPartnerLeft || !_isConnected)
                            ? null
                            : _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),

              /// EMOJI PICKER
              if (_showEmojiPicker)
                SizedBox(
                  height: 250,
                  child: emoji.EmojiPicker(
                    textEditingController: _textController,
                    onEmojiSelected: (category, emp) => _onTyping(),
                    config: emoji.Config(
                      emojiViewConfig: emoji.EmojiViewConfig(
                        backgroundColor: Theme.of(
                          context,
                        ).scaffoldBackgroundColor,
                      ),
                      categoryViewConfig: emoji.CategoryViewConfig(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        iconColorSelected: Theme.of(
                          context,
                        ).colorScheme.primary,
                        indicatorColor: Theme.of(context).colorScheme.primary,
                      ),
                      bottomActionBarConfig: emoji.BottomActionBarConfig(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        buttonColor: Theme.of(context).colorScheme.primary,
                        buttonIconColor: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
